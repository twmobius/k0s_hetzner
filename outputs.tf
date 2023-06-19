output "controller_ip4_addr" {
  value = hcloud_server.controller.*.ipv4_address
}

output "controller1_ip6_addr" {
  value = hcloud_server.controller.*.ipv6_address
}
