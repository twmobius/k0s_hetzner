output "controller_ip_addreses" {
  value = module.controller_ips.addresses
}

output "worker_ip_addreses" {
  value = module.worker_ips.addresses
}
