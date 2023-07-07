# Spread out for great chance a Hetzner outage doesn't impact us
resource "hcloud_placement_group" "controller-pg" {
  name = "controller-pg"
  type = "spread"
  labels = {
    "role" : replace(var.controller_role, "+", "-")
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
    "role" : replace(var.controller_role, "+", "-")
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
    "role" : replace(var.controller_role, "+", "-")
  }
}

# Create the controllers and link them to the above IPs
resource "hcloud_server" "controller" {
  count              = var.controller_role == "single" ? 1 : var.controller_count
  name               = var.controller_role == "single" ? var.single_controller_name : "controller${count.index}"
  server_type        = var.controller_server_type
  placement_group_id = hcloud_placement_group.controller-pg.id
  image              = var.controller_server_image
  location           = var.controller_server_location
  user_data = templatefile(
    "templates/user-data.tftpl",
    {
      fqdn = (var.controller_role == "single" ? format("%s.%s", var.single_controller_name, var.domain) :
      format("%s%s.%s", "controller", count.index, var.domain)),
      ip_addresses = join(" ", sort(
        concat(
          hcloud_primary_ip.controller_ipv4.*.ip_address,
          hcloud_primary_ip.controller_ipv6.*.ip_address,
          hcloud_primary_ip.worker_ipv4.*.ip_address,
          hcloud_primary_ip.worker_ipv6.*.ip_address,
      ))),
      controller_lb_addresses = (local.cp_balanced_controller_count == 0 ? "" :
        join(" ", sort(
          [hcloud_load_balancer.cp_load_balancer[0].ipv4, hcloud_load_balancer.cp_load_balancer[0].ipv6]
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
    "role" : replace(var.controller_role, "+", "-")
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

# DNS Reverse RRs
resource "hcloud_rdns" "controller_ipv4" {
  count         = var.controller_role == "single" ? 1 : var.controller_count
  primary_ip_id = hcloud_primary_ip.controller_ipv4[count.index].id
  ip_address    = hcloud_primary_ip.controller_ipv4[count.index].ip_address
  dns_ptr = (var.controller_role == "single" ?
    format("%s.%s", var.single_controller_name, var.domain) :
    format("%s.%s", hcloud_server.controller[count.index].name, var.domain)
  )
}

resource "hcloud_rdns" "controller_ipv6" {
  count         = var.controller_role == "single" ? 1 : var.controller_count
  primary_ip_id = hcloud_primary_ip.controller_ipv6[count.index].id
  ip_address    = hcloud_primary_ip.controller_ipv6[count.index].ip_address
  dns_ptr = (var.controller_role == "single" ?
    format("%s.%s", var.single_controller_name, var.domain) :
    format("%s.%s", hcloud_server.controller[count.index].name, var.domain)
  )
}

