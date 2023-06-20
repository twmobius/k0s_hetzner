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

  hosts = concat(
    [
      for address in hcloud_server.controller.*.ipv4_address :
      {
        role        = var.controller_role
        environment = { "ROLE" = var.controller_role }
        ssh = {
          address  = address
          port     = 22
          user     = "root"
          key_path = var.ssh_priv_key_path
        }
      }
    ],
    [
      for address in hcloud_server.worker.*.ipv4_address :
      {
        role        = "worker"
        environment = { "ROLE" = "worker" }
        ssh = {
          address  = address
          port     = 22
          user     = "root"
          key_path = var.ssh_priv_key_path
        }
      }
    ]
  )
}
