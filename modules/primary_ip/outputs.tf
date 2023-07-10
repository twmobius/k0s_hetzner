output "addresses" {
  value = {
    ipv4 = hcloud_primary_ip.ipv4.*.ip_address,
    ipv6 = hcloud_primary_ip.ipv6.*.ip_address,
  }
}

output "address_ids" {
  value = {
    ipv4 = hcloud_primary_ip.ipv4.*.id,
    ipv6 = hcloud_primary_ip.ipv6.*.id,
  }
}
