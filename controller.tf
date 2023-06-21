# Spread out for great chance a Hetzner outage doesn't impact us
resource "hcloud_placement_group" "controller-pg" {
  name = "controller-pg"
  type = "spread"
  labels = {
    "role" : var.controller_role
  }
}

# Create Primary IPs for servers. We need this to happen in a different step
# from creating the servers in order to populate ferm
resource "hcloud_primary_ip" "controller_ipv4" {
  count         = var.controller_role == "single" ? 1 : var.controller_count
  name          = "controller_ipv4_controller${count.index}"
  type          = "ipv4"
  datacenter    = var.controller_server_datacenter
  assignee_type = "server"
  auto_delete   = false # Per comment in provider documentation
  labels = {
    "role" : var.controller_role
  }
}

resource "hcloud_primary_ip" "controller_ipv6" {
  count         = var.controller_role == "single" ? 1 : var.controller_count
  name          = "controller_ipv6_controller${count.index}"
  type          = "ipv6"
  datacenter    = var.controller_server_datacenter
  assignee_type = "server"
  auto_delete   = false # Per comment in provider documentation
  labels = {
    "role" : var.controller_role
  }
}

# Create the controllers and link them to the above IPs
resource "hcloud_server" "controller" {
  count              = var.controller_role == "single" ? 1 : var.controller_count
  name               = "controller${count.index}"
  server_type        = var.controller_server_type
  placement_group_id = hcloud_placement_group.controller-pg.id
  image              = var.controller_server_image
  location           = var.controller_server_location
  user_data = templatefile(
    "user-data.tftpl",
    { ip_addresses = join(" ", sort(
      concat(
        hcloud_primary_ip.controller_ipv4.*.ip_address,
        hcloud_primary_ip.controller_ipv6.*.ip_address,
        hcloud_primary_ip.worker_ipv4.*.ip_address,
        hcloud_primary_ip.worker_ipv6.*.ip_address,
      )))
    }
  )
  ssh_keys = [
    hcloud_ssh_key.default.id
  ]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
    ipv4         = hcloud_primary_ip.controller_ipv4[count.index].id
    ipv6         = hcloud_primary_ip.controller_ipv6[count.index].id
  }
  labels = {
    "role" : var.controller_role
  }
}

# DNS Reverse RRs
resource "hcloud_rdns" "controller_ipv4" {
  count         = var.controller_count
  primary_ip_id = hcloud_primary_ip.controller_ipv4[count.index].id
  ip_address    = hcloud_primary_ip.controller_ipv4[count.index].ip_address
  dns_ptr       = format("%s.%s", hcloud_server.controller[count.index].name, var.domain)
}

resource "hcloud_rdns" "controller_ipv6" {
  count         = var.controller_count
  primary_ip_id = hcloud_primary_ip.controller_ipv6[count.index].id
  ip_address    = hcloud_primary_ip.controller_ipv6[count.index].ip_address
  dns_ptr       = format("%s.%s", hcloud_server.controller[count.index].name, var.domain)
}
