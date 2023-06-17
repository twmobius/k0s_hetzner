# Get our API key for hetzner
provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "default" {
  name       = "hetzner"
  public_key = var.ssh_key
}

# Create a new server running debian
resource "hcloud_server" "controller1" {
  name = "controller1"
  # arm64 machine
  server_type = var.hcloud_server_type
  # TODO: Bump to 12 once it's available
  image = "debian-11"
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
    "role" : "controller"
  }
}

resource "hcloud_rdns" "controller1_ipv4" {
  server_id  = hcloud_server.controller1.id
  ip_address = hcloud_server.controller1.ipv4_address
  dns_ptr    = var.controller1_rdns
}

resource "hcloud_rdns" "controller1_ipv6" {
  server_id  = hcloud_server.controller1.id
  ip_address = hcloud_server.controller1.ipv6_address
  dns_ptr    = var.controller1_rdns
}
