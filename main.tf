# Get our API key for hetzner
provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "default" {
  name       = "hetzner"
  public_key = var.ssh_key
}

# Create a new server running debian
resource "hcloud_server" "controller" {
  count = var.controller_count
  name = "controller${count.index}"
  # arm64 machine
  server_type = var.hcloud_server_type
  # TODO: Bump to 12 once it's available
  image = var.hcloud_server_image
  # Only falkenstein has arm64 for now
  location  = var.hcloud_server_location
  user_data = file("user-data")
  ssh_keys = [
    hcloud_ssh_key.default.id
  ]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  labels = {
    # TODO: These are arbitrary hetzner labels. Figure out a use for them
    "role" : "controller"
  }
}

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
