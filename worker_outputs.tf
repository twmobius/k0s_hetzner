output "worker_ip4_addr" {
  value = hcloud_server.worker.*.ipv4_address
}

output "worker_ip6_addr" {
  value = hcloud_server.worker.*.ipv6_address
}
