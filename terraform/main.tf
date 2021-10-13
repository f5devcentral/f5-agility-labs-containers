provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

#----- Create VPC -----

resource "aws_vpc" "lab_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.cluster_name}_vpc"
    Lab  = "okd4"
  }
}

# Subnets

resource "aws_subnet" "az1_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.cidrs["az1"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name                                                             = "${var.cluster_name}_az1"
    "kubernetes.io/cluster/${data.external.okd_name.result["name"]}" = "shared"
    Lab                                                              = "okd4"
  }
}

# Internet gateway

resource "aws_internet_gateway" "lab_internet_gw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "${var.cluster_name}_igw"
    Lab  = "okd4"
  }
}

# Route tables

resource "aws_route_table" "lab_public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_internet_gw.id
  }

  tags = {
    Name = "${var.cluster_name}_public_rt"
    Lab  = "okd4"
  }
}

resource "aws_route_table_association" "az1_assoc" {
  subnet_id      = aws_subnet.az1_subnet.id
  route_table_id = aws_route_table.lab_public_rt.id
}

# Network load balancers

resource "aws_lb" "ext_lb" {
  name               = "${var.cluster_name}-extlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.az1_subnet.*.id

  enable_deletion_protection = false

  tags = {
    Lab = "okd4"
  }
}

resource "aws_lb_target_group" "ext_tg_6443" {
  name                 = "${var.cluster_name}-ext-6443"
  vpc_id               = aws_vpc.lab_vpc.id
  target_type          = "ip"
  protocol             = "TCP"
  port                 = 6443
  deregistration_delay = 60

  health_check {
    enabled             = true
    port                = 6443
    protocol            = "HTTPS"
    path                = "/readyz"
    interval            = 10
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "ext_6443" {
  load_balancer_arn = aws_lb.ext_lb.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ext_tg_6443.arn
  }
}

resource "aws_lb_target_group" "ext_tg_443" {
  name                 = "${var.cluster_name}-ext-443"
  vpc_id               = aws_vpc.lab_vpc.id
  target_type          = "ip"
  protocol             = "TCP"
  port                 = 443
  deregistration_delay = 60

  health_check {
    enabled  = true
    port     = 443
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "ext_443" {
  load_balancer_arn = aws_lb.ext_lb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ext_tg_443.arn
  }
}

resource "aws_lb_target_group" "ext_tg_80" {
  name                 = "${var.cluster_name}-ext-80"
  vpc_id               = aws_vpc.lab_vpc.id
  target_type          = "ip"
  protocol             = "TCP"
  port                 = 80
  deregistration_delay = 60

  health_check {
    enabled  = true
    port     = 80
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "ext_80" {
  load_balancer_arn = aws_lb.ext_lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ext_tg_80.arn
  }
}

resource "aws_lb" "int_lb" {
  name               = "${var.cluster_name}-intlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.az1_subnet.*.id

  enable_deletion_protection = false

  tags = {
    Lab = "okd4"
  }
}

resource "aws_lb_target_group" "int_tg_6443" {
  name                 = "${var.cluster_name}-int-6443"
  vpc_id               = aws_vpc.lab_vpc.id
  target_type          = "ip"
  protocol             = "TCP"
  port                 = 6443
  deregistration_delay = 60

  health_check {
    enabled             = true
    port                = 6443
    protocol            = "HTTPS"
    path                = "/readyz"
    interval            = 10
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "int_6443" {
  load_balancer_arn = aws_lb.int_lb.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.int_tg_6443.arn
  }
}

resource "aws_lb_target_group" "int_tg_22623" {
  name                 = "${var.cluster_name}-int-22623"
  vpc_id               = aws_vpc.lab_vpc.id
  target_type          = "ip"
  protocol             = "TCP"
  port                 = 22623
  deregistration_delay = 60

  health_check {
    enabled             = true
    port                = 22623
    protocol            = "HTTPS"
    path                = "/healthz"
    interval            = 10
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "int_22623" {
  load_balancer_arn = aws_lb.int_lb.arn
  port              = "22623"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.int_tg_22623.arn
  }
}

resource "aws_lb_target_group" "int_tg_443" {
  name                 = "${var.cluster_name}-int-443"
  vpc_id               = aws_vpc.lab_vpc.id
  target_type          = "ip"
  protocol             = "TCP"
  port                 = 443
  deregistration_delay = 60

  health_check {
    enabled  = true
    port     = 443
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "int_443" {
  load_balancer_arn = aws_lb.int_lb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.int_tg_443.arn
  }
}

resource "aws_lb_target_group" "int_tg_80" {
  name                 = "${var.cluster_name}-int-80"
  vpc_id               = aws_vpc.lab_vpc.id
  target_type          = "ip"
  protocol             = "TCP"
  port                 = 80
  deregistration_delay = 60

  health_check {
    enabled  = true
    port     = 80
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "int_80" {
  load_balancer_arn = aws_lb.int_lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.int_tg_80.arn
  }
}

# Route53

resource "aws_route53_zone" "private_zone" {
  name          = "${var.cluster_name}.${var.public_domain}"
  force_destroy = true

  vpc {
    vpc_id = aws_vpc.lab_vpc.id
  }

  tags = {
    Name                                                             = "${data.external.okd_name.result["name"]}-int"
    "kubernetes.io/cluster/${data.external.okd_name.result["name"]}" = "owned"
    Lab                                                              = "okd4"
  }
}

data "aws_route53_zone" "private" {
  name         = "${var.cluster_name}.${var.public_domain}"
  vpc_id       = aws_vpc.lab_vpc.id
  private_zone = true

  depends_on = [
    aws_route53_zone.private_zone
  ]
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.private.zone_id
  name    = "api.${data.aws_route53_zone.private.name}"
  type    = "A"

  depends_on = [
    aws_lb.int_lb,
    data.aws_route53_zone.private
  ]

  alias {
    name                   = aws_lb.int_lb.dns_name
    zone_id                = aws_lb.int_lb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api-int" {
  zone_id = data.aws_route53_zone.private.zone_id
  name    = "api-int.${data.aws_route53_zone.private.name}"
  type    = "A"

  depends_on = [
    aws_lb.int_lb,
    data.aws_route53_zone.private
  ]

  alias {
    name                   = aws_lb.int_lb.dns_name
    zone_id                = aws_lb.int_lb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "apps-int" {
  zone_id = data.aws_route53_zone.private.zone_id
  name    = "*.apps.${data.aws_route53_zone.private.name}"
  type    = "A"

  depends_on = [
    aws_lb.int_lb,
    data.aws_route53_zone.private
  ]

  alias {
    name                   = aws_lb.int_lb.dns_name
    zone_id                = aws_lb.int_lb.zone_id
    evaluate_target_health = false
  }
}

#----- Set default SSH key pair -----

resource "aws_key_pair" "lab_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

#----- Deploy OpenShift -----

module "okd" {
  source            = "./okd"
  aws_region        = var.aws_region
  aws_profile       = var.aws_profile
  myIP              = "${chomp(data.http.myIP.body)}/32"
  key_name          = var.key_name
  master_inst_type  = var.master_inst_type
  master_count      = var.master_count
  worker_inst_type  = var.worker_inst_type
  worker_count      = var.worker_count
  vpc_id            = aws_vpc.lab_vpc.id
  vpc_cidr          = var.vpc_cidr
  vpc_subnet        = [aws_subnet.az1_subnet.id]
  private_domain    = data.aws_route53_zone.private.name
  private_domain_id = data.aws_route53_zone.private.zone_id
  cluster_name      = var.cluster_name
  okd_name          = data.external.okd_name.result["name"]
  int_tg_22623      = aws_lb_target_group.int_tg_22623.arn
  int_tg_6443       = aws_lb_target_group.int_tg_6443.arn
  int_tg_80         = aws_lb_target_group.int_tg_80.arn
  int_tg_443        = aws_lb_target_group.int_tg_443.arn
  ext_tg_6443       = aws_lb_target_group.ext_tg_6443.arn
  ext_tg_80         = aws_lb_target_group.ext_tg_80.arn
  ext_tg_443        = aws_lb_target_group.ext_tg_443.arn
}

