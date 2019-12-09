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
    Name = "lab_vpc"
    Lab  = "Containers"
  }
}

# Internet gateway

resource "aws_internet_gateway" "lab_internet_gateway" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "lab_igw"
    Lab  = "Containers"
  }
}

# Route tables

resource "aws_route_table" "lab_public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_internet_gateway.id
  }

  tags = {
    Name = "lab_public"
    Lab  = "Containers"
  }
}

resource "aws_default_route_table" "lab_private_rt" {
  default_route_table_id = aws_vpc.lab_vpc.default_route_table_id

  tags = {
    Name = "lab_private"
    Lab  = "Containers"
  }
}

# Subnets

resource "aws_subnet" "mgmt1_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.cidrs["mgmt1"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "lab_mgmt1"
    Lab  = "Containers"
  }
}

resource "aws_subnet" "external1_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.cidrs["external1"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "lab_external1"
    Lab  = "Containers"
  }
}

resource "aws_subnet" "internal1_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.cidrs["internal1"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "lab_internal1"
    Lab  = "Containers"
  }
}

resource "aws_route_table_association" "lab_mgmt1_assoc" {
  subnet_id      = aws_subnet.mgmt1_subnet.id
  route_table_id = aws_route_table.lab_public_rt.id
}

resource "aws_route_table_association" "lab_external1_assoc" {
  subnet_id      = aws_subnet.external1_subnet.id
  route_table_id = aws_route_table.lab_public_rt.id
}

resource "aws_route_table_association" "lab_internal1_assoc" {
  subnet_id      = aws_subnet.internal1_subnet.id
  route_table_id = aws_default_route_table.lab_private_rt.id
}

#----- Set default SSH key pair -----
resource "aws_key_pair" "lab_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

#----- Deploy Big-IP -----
module "bigip" {
  source              = "./bigip"
  aws_region          = var.aws_region
  aws_profile         = var.aws_profile
  myIP                = "${chomp(data.http.myIP.body)}/32"
  key_name            = var.key_name
  instance_type       = var.bigip_instance_type
  bigip_count         = var.bigip_count
  bigip_ami_prod_code = var.bigip_ami_prod_code
  bigip_ami_name_filt = var.bigip_ami_name_filt
  bigip_admin         = var.bigip_admin
  do_rpm              = var.do_rpm
  as3_rpm             = var.as3_rpm
  vpc_id              = aws_vpc.lab_vpc.id
  vpc_cidr            = var.vpc_cidr
  vpc_subnet          = [aws_subnet.mgmt1_subnet.id, aws_subnet.external1_subnet.id, aws_subnet.internal1_subnet.id]
}

#----- Deploy Kubernetes -----
module "kube" {
  source        = "./kubernetes"
  aws_region    = var.aws_region
  aws_profile   = var.aws_profile
  myIP          = "${chomp(data.http.myIP.body)}/32"
  key_name      = var.key_name
  instance_type = var.kube_instance_type
  kube_count    = var.kube_count
  vpc_id        = aws_vpc.lab_vpc.id
  vpc_cidr      = var.vpc_cidr
  vpc_subnet    = [aws_subnet.external1_subnet.id]
}

#----- Deploy OpenShift -----
module "okd" {
  source        = "./openshift"
  aws_region    = var.aws_region
  aws_profile   = var.aws_profile
  myIP          = "${chomp(data.http.myIP.body)}/32"
  key_name      = var.key_name
  instance_type = var.okd_instance_type
  okd_count     = var.okd_count
  vpc_id        = aws_vpc.lab_vpc.id
  vpc_cidr      = var.vpc_cidr
  vpc_subnet    = [aws_subnet.external1_subnet.id]
}

