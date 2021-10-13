variable "aws_profile" {
}

variable "aws_region" {
}

variable "vpc_cidr" {
}

data "aws_availability_zones" "available" {
}

variable "cidrs" {
  type = map(string)
}

data "http" "myIP" {
  url = "https://api.ipify.org/"
}

variable "key_name" {
}

variable "public_key_path" {
}

variable "master_inst_type" {
}

variable "master_count" {
}

variable "worker_inst_type" {
}

variable "worker_count" {
}

variable "public_domain" {
}

variable "cluster_name" {
}

data "external" "okd_name" {
  program = ["bash", "scripts/get_okd_name.sh"]
}

