#--------root/outputs.tf--------
output "BIGIP_Admin_URL" {
  value = module.bigip.public_dns
}

output "BIIGP_Mgmt_IP" {
  value = module.bigip.public_ip
}

output "BIGIP_Admin_Password" {
  value = module.bigip.password
}

output "KUBE_Cluster_IPs" {
  value = module.kube.public_ip
}

output "OKD_Cluster_IPs" {
  value = module.okd.public_ip
}

