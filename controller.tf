# Create controller servers

resource "hcloud_placement_group" "controller-pg" {
  name = "controller-pg"
  type = "spread"
  labels = {
    "role" : var.controller_role
  }
}

resource "hcloud_server" "controller" {
  count              = var.controller_role == "single" ? 1 : var.controller_count
  name               = "controller${count.index}"
  server_type        = var.controller_server_type
  placement_group_id = hcloud_placement_group.controller-pg.id
  image              = var.controller_server_image
  location           = var.controller_server_location
  user_data          = file("user-data")
  ssh_keys = [
    hcloud_ssh_key.default.id
  ]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  labels = {
    "role" : var.controller_role
  }
}

# DNS Reverse RRs
resource "hcloud_rdns" "controller_ipv4" {
  count      = var.controller_count
  server_id  = hcloud_server.controller[count.index].id
  ip_address = hcloud_server.controller[count.index].ipv4_address
  dns_ptr    = format("%s.%s", hcloud_server.controller[count.index].name, var.domain)
}

resource "hcloud_rdns" "controller_ipv6" {
  count      = var.controller_count
  server_id  = hcloud_server.controller[count.index].id
  ip_address = hcloud_server.controller[count.index].ipv6_address
  dns_ptr    = format("%s.%s", hcloud_server.controller[count.index].name, var.domain)
}
