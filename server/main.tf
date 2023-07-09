locals {
  enable_ipv6 = length(var.ip_addresses["ipv6"]) > 0 ? true : false
  enable_ipv4 = length(var.ip_addresses["ipv4"]) > 0 ? true : false
  firewall_rules = {
    for name, rule in var.firewall_rules :
    name => {
      proto = rule.proto,
      ports = join(" ", rule.ports),
      cidrs = join(" ", rule.cidrs),
    }
  }
}

# Push the SSH public key to hetzner
resource "hcloud_ssh_key" "default" {
  name       = "hetzner"
  public_key = var.ssh_pub_key
}

# Spread out for great chance a Hetzner outage doesn't impact us
resource "hcloud_placement_group" "pg" {
  name = "${var.role}-pg"
  type = "spread"
  labels = {
    "role" : var.role
  }
}

# Create servers and link them to the above IPs
resource "hcloud_server" "server" {
  count              = var.amount
  name               = "${var.role}-${count.index}"
  server_type        = var.type
  placement_group_id = hcloud_placement_group.pg.id
  image              = var.image
  datacenter         = var.datacenter
  user_data = templatefile(
    "server/templates/user-data.tftpl",
    {
      fqdn           = format("%s-%s.%s", var.role, count.index, var.domain),
      firewall_rules = local.firewall_rules,
    }
  )
  ssh_keys = [
    hcloud_ssh_key.default.id
  ]
  public_net {
    ipv4_enabled = local.enable_ipv4
    ipv6_enabled = local.enable_ipv6
    ipv4         = var.ip_addresses["ipv4"][count.index]
    ipv6         = var.ip_addresses["ipv6"][count.index]
  }
  labels = {
    "role" : var.role
  }

  # Note: this will need to be reworked to apply to non-ipv4 and non public IP situations
  connection {
    type        = "ssh"
    user        = "root"
    host        = self.ipv4_address
    private_key = file(var.ssh_priv_key_path)
  }

  provisioner "remote-exec" {
    inline = ["cloud-init status --wait"]
  }
}
