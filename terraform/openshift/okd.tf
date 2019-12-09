data "aws_ami" "centos_ami" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }

  filter {
    name   = "name"
    values = ["CentOS Linux 7*"]
  }
}

resource "aws_security_group" "okd_sg" {
  name   = "okd_sg"
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
    Name = "okd_sg"
    Lab  = "Containers"
  }
}

resource "aws_instance" "okd" {
  ami                    = data.aws_ami.centos_ami.id
  instance_type          = var.instance_type
  count                  = var.okd_count
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.okd_sg.id]
  subnet_id              = var.vpc_subnet[0]

  root_block_device {
    volume_size           = 20
    delete_on_termination = true
  }

  tags = {
    Name = "${count.index == 0 ? "okd-master1" : "okd-node${count.index}"}"
    Lab  = "Containers"
  }
}

# write out centos inventory
data "template_file" "inventory" {
  template = <<EOF
[all]
%{ for instance in aws_instance.okd ~}
${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
%{ endfor ~}

[masters]
%{ for instance in aws_instance.okd ~}
%{ if substr(instance.tags.Name, 4, 6) == "master" }${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}%{ endif }
%{ endfor ~}

[nodes]
%{ for instance in aws_instance.okd ~}
%{ if substr(instance.tags.Name, 4, 4) == "node" }${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}%{ endif }
%{ endfor ~}

[all:vars]
ansible_user=centos
ansible_playbook_python=/usr/bin/python3

EOF
}

resource "local_file" "save_inventory" {
  depends_on = [data.template_file.inventory]
  content    = data.template_file.inventory.rendered
  filename   = "./openshift/ansible/inventory.ini"
}

# write out okd inventory
data "template_file" "inventory-okd" {
  template = <<EOF
[OSEv3:children]
masters
nodes
etcd

[masters]
%{ for instance in aws_instance.okd ~}
%{ if substr(instance.tags.Name, 4, 6) == "master" }${instance.tags.Name}%{ endif }
%{ endfor ~}

[etcd]
%{ for instance in aws_instance.okd ~}
%{ if substr(instance.tags.Name, 4, 6) == "master" }${instance.tags.Name}%{ endif }
%{ endfor ~}

[nodes]
%{ for instance in aws_instance.okd ~}
%{ if substr(instance.tags.Name, 4, 6) == "master" }${instance.tags.Name} openshift_public_hostname=${instance.tags.Name} openshift_schedulable=true openshift_node_group_name="node-config-master-infra"%{ else }${instance.tags.Name} openshift_public_hostname=${instance.tags.Name} openshift_schedulable=true openshift_node_group_name="node-config-compute"%{ endif }
%{ endfor ~}

[OSEv3:vars]
ansible_ssh_user=centos
ansible_become=true
enable_excluders=false
enable_docker_excluder=false
ansible_service_broker_install=false

containerized=true
openshift_disable_check=disk_availability,memory_availability,docker_storage,docker_image_ava

deployment_type=origin
openshift_deployment_type=origin

openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]

openshift_master_api_port=8443
openshift_master_console_port=8443

openshift_metrics_install_metrics=false
openshift_logging_install_logging=false

EOF
}

resource "local_file" "save_inventory-okd" {
  depends_on = [data.template_file.inventory-okd]
  content    = data.template_file.inventory-okd.rendered
  filename   = "./openshift/ansible/inventory-okd.ini"
}

#----- Run Ansible Playbook -----
resource "null_resource" "ansible" {
  provisioner "local-exec" {
    working_dir = "./openshift/ansible/"

    command = <<EOF
    aws ec2 wait instance-status-ok --region ${var.aws_region} --profile ${var.aws_profile} --instance-ids ${join(" ", aws_instance.okd.*.id)}
    ansible-playbook ./playbooks/deploy-okd.yaml
    EOF
  }
}

#----- Install OpenShift -----
resource "null_resource" "okd" {
  depends_on = [null_resource.ansible]
  provisioner "remote-exec" {
    connection {
      host = aws_instance.okd.0.public_ip
      type = "ssh"
      user = "centos"
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
    "ansible-playbook -i $HOME/inventory.ini $HOME/openshift-ansible/playbooks/prerequisites.yml",
    "ansible-playbook -i $HOME/inventory.ini $HOME/openshift-ansible/playbooks/deploy_cluster.yml",
    "sudo htpasswd -b /etc/origin/master/htpasswd centos centos",
    "oc adm policy add-cluster-role-to-user cluster-admin centos",
    ]
  }
}

#-------- okd output --------

output "public_ip" {
  value = formatlist(
  "%s = %s",
  aws_instance.okd.*.tags.Name,
  aws_instance.okd.*.public_ip
  )
}

