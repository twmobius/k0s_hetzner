# Get our API key for hetzner
provider "hcloud" {
  token = var.hcloud_token
}

# Create a new server running debian
resource "hcloud_server" "controller1" {
  name = "controller1"
  # arm64 machine
  server_type = "cax11"
  # TODO: Bump to 12 once it's available
  image = "debian-11"
  # Only falkenstein has arm64 for now
  location  = "fsn1"
  user_data = file("user-data")
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  labels = {
    "role" : "controller"
  }
}
