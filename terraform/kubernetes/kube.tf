data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-*-amd64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "kube_sg" {
  name   = "kube_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myIP]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.myIP]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.myIP]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kube_sg"
    Lab  = "Containers"
  }
}

resource "aws_instance" "kube" {
  ami                    = data.aws_ami.ubuntu_ami.id
  instance_type          = var.instance_type
  count                  = var.kube_count
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.kube_sg.id]
  subnet_id              = var.vpc_subnet[0]

  root_block_device {
    volume_size           = 20
    delete_on_termination = true
  }

  tags = {
    Name = "${count.index == 0 ? "kube-master1" : "kube-node${count.index}"}"
    Lab  = "Containers"
  }
}

# write out kube inventory
data "template_file" "inventory" {
  template = <<EOF
[all]
%{ for instance in aws_instance.kube ~}
${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
%{ endfor ~}

[masters]
%{ for instance in aws_instance.kube ~}
%{ if substr(instance.tags.Name, 5, 6) == "master" }${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}%{ endif }
%{ endfor ~}

[nodes]
%{ for instance in aws_instance.kube ~}
%{ if substr(instance.tags.Name, 5, 4) == "node" }${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}%{ endif }
%{ endfor ~}

[all:vars]
ansible_user=ubuntu
ansible_python_interpreter=/usr/bin/python3
EOF

}

resource "local_file" "save_inventory" {
  depends_on = [data.template_file.inventory]
  content = data.template_file.inventory.rendered
  filename = "./kubernetes/ansible/inventory.ini"
}

#----- Run Ansible Playbook -----
resource "null_resource" "ansible" {
  provisioner "local-exec" {
    working_dir = "./kubernetes/ansible/"

    command = <<EOF
    aws ec2 wait instance-status-ok --region ${var.aws_region} --profile ${var.aws_profile} --instance-ids ${join(" ", aws_instance.kube.*.id)}
    ansible-playbook ./playbooks/deploy-kube.yaml
    EOF
  }
}

#-------- kube output --------

output "public_ip" {
  value = formatlist(
  "%s = %s",
  aws_instance.kube.*.tags.Name,
  aws_instance.kube.*.public_ip
  )
}

