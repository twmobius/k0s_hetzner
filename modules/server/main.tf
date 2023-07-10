locals {
  enable_ipv6 = length(var.ip_address_ids["ipv6"]) > 0 ? true : false
  enable_ipv4 = length(var.ip_address_ids["ipv4"]) > 0 ? true : false
  firewall_rules = {
    for name, rule in var.firewall_rules :
    name => {
      proto = rule.proto,
      ports = join(" ", rule.ports),
      cidrs = join(" ", rule.cidrs),
    }
  }
  role = replace(var.role, "+", "-")
}

# Spread out for great chance a Hetzner outage doesn't impact us
resource "hcloud_placement_group" "pg" {
  name = "${local.role}-pg"
  type = "spread"
  labels = {
    "role" : local.role,
  }
}

# Create servers and link them to the above IPs
resource "hcloud_server" "server" {
  count              = var.amount
  name               = var.hostname != null ? var.hostname : "${local.role}-${count.index}"
  server_type        = var.type
  placement_group_id = hcloud_placement_group.pg.id
  image              = var.image
  datacenter         = var.datacenter
  user_data = templatefile(
    "modules/server/templates/user-data.tftpl",
    {
      fqdn = format("%s.%s",
        var.hostname != null ? var.hostname : "${local.role}-${count.index}",
        var.domain,
      )
      firewall_rules = local.firewall_rules,
    }
  )
  ssh_keys = [
    var.ssh_pub_key_id
  ]
  public_net {
    ipv4_enabled = local.enable_ipv4
    ipv6_enabled = local.enable_ipv6
    ipv4         = var.ip_address_ids["ipv4"][count.index]
    ipv6         = var.ip_address_ids["ipv6"][count.index]
  }
  labels = {
    "role" : local.role,
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
