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
  url = "http://ipv4.icanhazip.com"
}

variable "key_name" {
}

variable "public_key_path" {
}

variable "kube_instance_type" {
}

variable "kube_count" {
}

variable "okd_instance_type" {
}

variable "okd_count" {
}

variable "bigip_instance_type" {
}

variable "bigip_count" {
}

variable "bigip_ami_prod_code" {
}

variable "bigip_ami_name_filt" {
}

variable "bigip_admin" {
}

variable "do_rpm" {
}

variable "as3_rpm" {
}

