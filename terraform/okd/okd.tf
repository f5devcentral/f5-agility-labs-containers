data "aws_ami" "fcos_ami" {
  most_recent = true
  owners      = ["125523088429"]

  filter {
    name   = "name"
    values = ["fedora-coreos-34*"]
  }

  filter {
    name   = "description"
    values = ["Fedora CoreOS stable*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Route53

resource "aws_route53_record" "etcd" {
  count   = length(aws_instance.okd-master)
  zone_id = var.private_domain_id
  name    = "etcd-${count.index}.${var.private_domain}"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.okd-master[count.index].private_ip]
}

resource "aws_route53_record" "etcd-srv" {
  zone_id = var.private_domain_id
  name    = "_etcd-server-ssl._tcp.${var.private_domain}"
  type    = "SRV"
  ttl     = "60"
  records = [for name in aws_route53_record.etcd : "0 10 2380 ${name.fqdn}"]
}

# Security Groups

resource "aws_security_group" "okd_bootstrap_sg" {
  name   = "${var.cluster_name}_bootstrap_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myIP]
  }

  ingress {
    from_port   = 19531
    to_port     = 19531
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
    Name = "${var.cluster_name}_bootstrap_sg"
    Lab  = "okd4"
  }
}

resource "aws_security_group" "okd_cluster_sg" {
  name   = "${var.cluster_name}_cluster_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "${var.cluster_name}_cluster_sg"
    Lab  = "okd4"
  }
}

# S3

resource "aws_s3_bucket" "okd-infra" {
  bucket        = "${var.okd_name}-infra"
  acl           = "private"
  force_destroy = true

  tags = {
    Name = "${var.okd_name}-infra"
    Lab  = "okd4"
  }
}

resource "aws_s3_bucket_object" "copy-bootstrap" {
  bucket       = aws_s3_bucket.okd-infra.id
  key          = "bootstrap.ign"
  source       = "${path.root}/ignition/bootstrap.ign"
  content_type = "binary/octet-stream"
  acl          = "public-read"
}

resource "aws_s3_bucket_object" "copy-master" {
  bucket       = aws_s3_bucket.okd-infra.id
  key          = "master.ign"
  source       = "${path.root}/ignition/master.ign"
  content_type = "binary/octet-stream"
  acl          = "public-read"
}

resource "aws_s3_bucket_object" "copy-worker" {
  bucket       = aws_s3_bucket.okd-infra.id
  key          = "worker.ign"
  source       = "${path.root}/ignition/worker.ign"
  content_type = "binary/octet-stream"
  acl          = "public-read"
}

# IAM

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "okd-iam-role" {
  name               = "${var.cluster_name}-okd-iam-role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  path               = "/"

  inline_policy {
    name = "${var.cluster_name}-okd-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["ec2:*"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_iam_instance_profile" "okd_profile" {
  name = "${var.cluster_name}-okd-iam-profile"
  role = aws_iam_role.okd-iam-role.name
}

# EC2

locals {
  bootstrap-ign = jsonencode({
    "ignition" : { "config" : { "replace" : { "source" : "https://${var.okd_name}-infra.s3-${var.aws_region}.amazonaws.com/bootstrap.ign" } }, "version" : "3.2.0" }
  })
}

resource "aws_instance" "okd-bootstrap" {
  ami                         = data.aws_ami.fcos_ami.id
  instance_type               = "m5.large"
  count                       = 1
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.okd_bootstrap_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.okd_profile.name
  subnet_id                   = var.vpc_subnet[0]
  associate_public_ip_address = true
  #private_ip                  = "${lookup(var.okd_ips,count.index)}"
  user_data                   = local.bootstrap-ign

  root_block_device {
    volume_size           = 100
    delete_on_termination = true
  }

  depends_on = [
    aws_s3_bucket_object.copy-bootstrap
  ]

  tags = {
    Name = "okd-bootstrap"
    Lab  = "okd4"
  }
}

resource "aws_lb_target_group_attachment" "bootstrap-ext-6443" {
  count            = length(aws_instance.okd-bootstrap)
  target_group_arn = var.ext_tg_6443
  target_id        = aws_instance.okd-bootstrap[count.index].private_ip
  port             = 6443
}

resource "aws_lb_target_group_attachment" "bootstrap-int-6443" {
  count            = length(aws_instance.okd-bootstrap)
  target_group_arn = var.int_tg_6443
  target_id        = aws_instance.okd-bootstrap[count.index].private_ip
  port             = 6443
}

resource "aws_lb_target_group_attachment" "bootstrap-int-22623" {
  count            = length(aws_instance.okd-bootstrap)
  target_group_arn = var.int_tg_22623
  target_id        = aws_instance.okd-bootstrap[count.index].private_ip
  port             = 22623
}

locals {
  master-ign = jsonencode({
    "ignition" : { "config" : { "replace" : { "source" : "https://${var.okd_name}-infra.s3-${var.aws_region}.amazonaws.com/master.ign" } }, "version" : "3.2.0" }
  })
}

resource "aws_instance" "okd-master" {
  ami                         = data.aws_ami.fcos_ami.id
  instance_type               = var.master_inst_type
  count                       = var.master_count
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.okd_cluster_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.okd_profile.name
  subnet_id                   = var.vpc_subnet[0]
  associate_public_ip_address = true
  #private_ip                  = "${lookup(var.okd_ips,count.index + 1)}"
  user_data = local.master-ign

  root_block_device {
    volume_size           = 100
    delete_on_termination = true
  }

  depends_on = [
    aws_instance.okd-bootstrap
  ]

  tags = {
    Name                                    = "okd-master-${count.index + 1}"
    Lab                                     = "okd4"
    "kubernetes.io/cluster/${var.okd_name}" = "shared"
  }
}

resource "aws_lb_target_group_attachment" "master-ext-6443" {
  count            = length(aws_instance.okd-master)
  target_group_arn = var.ext_tg_6443
  target_id        = aws_instance.okd-master[count.index].private_ip
  port             = 6443
}

resource "aws_lb_target_group_attachment" "master-int-6443" {
  count            = length(aws_instance.okd-master)
  target_group_arn = var.int_tg_6443
  target_id        = aws_instance.okd-master[count.index].private_ip
  port             = 6443
}

resource "aws_lb_target_group_attachment" "master-int-22623" {
  count            = length(aws_instance.okd-master)
  target_group_arn = var.int_tg_22623
  target_id        = aws_instance.okd-master[count.index].private_ip
  port             = 22623
}

locals {
  worker-ign = jsonencode({
    "ignition" : { "config" : { "replace" : { "source" : "https://${var.okd_name}-infra.s3-${var.aws_region}.amazonaws.com/worker.ign" } }, "version" : "3.2.0" }
  })
}

resource "aws_instance" "okd-worker" {
  ami                         = data.aws_ami.fcos_ami.id
  instance_type               = var.worker_inst_type
  count                       = var.worker_count
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.okd_cluster_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.okd_profile.name
  subnet_id                   = var.vpc_subnet[0]
  associate_public_ip_address = true
  #private_ip                  = "${lookup(var.okd_ips,count.index + 4)}"
  user_data = local.worker-ign

  root_block_device {
    volume_size           = 100
    delete_on_termination = true
  }

  depends_on = [
    aws_instance.okd-master
  ]

  tags = {
    Name                                    = "okd-worker-${count.index + 1}"
    Lab                                     = "okd4"
    "kubernetes.io/cluster/${var.okd_name}" = "shared"
  }
}

resource "aws_lb_target_group_attachment" "worker-ext-80" {
  count            = length(aws_instance.okd-worker)
  target_group_arn = var.ext_tg_80
  target_id        = aws_instance.okd-worker[count.index].private_ip
  port             = 80
}

resource "aws_lb_target_group_attachment" "worker-ext-443" {
  count            = length(aws_instance.okd-worker)
  target_group_arn = var.ext_tg_443
  target_id        = aws_instance.okd-worker[count.index].private_ip
  port             = 443
}

resource "aws_lb_target_group_attachment" "worker-int-80" {
  count            = length(aws_instance.okd-worker)
  target_group_arn = var.int_tg_80
  target_id        = aws_instance.okd-worker[count.index].private_ip
  port             = 80
}

resource "aws_lb_target_group_attachment" "worker-int-443" {
  count            = length(aws_instance.okd-worker)
  target_group_arn = var.int_tg_443
  target_id        = aws_instance.okd-worker[count.index].private_ip
  port             = 443
}

#-------- okd output --------

#output "master-public_ip" {
#  value = formatlist(
#  "%s = %s",
#  aws_instance.okd-master.*.tags.Name,
#  aws_instance.okd-master.*.public_ip
#  )
#}

#output "worker-public_ip" {
#  value = formatlist(
#  "%s = %s",
#  aws_instance.okd-worker.*.tags.Name,
#  aws_instance.okd-worker.*.public_ip
#  )
#}

