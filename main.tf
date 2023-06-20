# Get our API key for hetzner
provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "default" {
  name       = "hetzner"
  public_key = var.ssh_pub_key
}

resource "k0s_cluster" "k0s1" {
  name    = var.domain
  version = var.k0s_version

  hosts = [
    for address in hcloud_server.controller.*.ipv6_address :
    {
      role      = "controller+worker"
      no_taints = true
      # install_flags = ""
      ssh = {
        address  = address
        port     = 22
        user     = "root"
        key_path = var.ssh_priv_key_path
      }
    }
  ]
}
