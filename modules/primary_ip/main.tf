locals {
  ipv6_count = var.enable_ipv6 ? var.amount : 0
  ipv4_count = var.enable_ipv4 ? var.amount : 0
  role       = replace(var.role, "+", "-")
}

# Create Primary IPs for servers. We need this to happen in a different step
# from creating the servers in order to populate firewall rules
resource "hcloud_primary_ip" "ipv4" {
  count         = local.ipv4_count
  name          = var.hostname != null ? var.hostname : "${local.role}-${count.index}"
  type          = "ipv4"
  datacenter    = var.datacenter
  assignee_type = "server"
  auto_delete   = false # Per comment in provider documentation
  labels = {
    "role" : local.role
  }
}

resource "hcloud_primary_ip" "ipv6" {
  count         = local.ipv6_count
  name          = var.hostname != null ? var.hostname : "${local.role}-${count.index}"
  type          = "ipv6"
  datacenter    = var.datacenter
  assignee_type = "server"
  auto_delete   = false # Per comment in provider documentation
  labels = {
    "role" : local.role
  }
}

# DNS Reverse RRs
resource "hcloud_rdns" "ipv4" {
  count         = local.ipv4_count
  primary_ip_id = hcloud_primary_ip.ipv4[count.index].id
  ip_address    = hcloud_primary_ip.ipv4[count.index].ip_address
  dns_ptr       = format("%s.%s", hcloud_primary_ip.ipv4[count.index].name, var.domain)
}

resource "hcloud_rdns" "ipv6" {
  count         = local.ipv6_count
  primary_ip_id = hcloud_primary_ip.ipv6[count.index].id
  ip_address    = hcloud_primary_ip.ipv6[count.index].ip_address
  dns_ptr       = format("%s.%s", hcloud_primary_ip.ipv6[count.index].name, var.domain)
}
