# Get our API key for hetzner
provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "default" {
  name       = "hetzner"
  public_key = var.ssh_pub_key
}

module "worker_ips" {
  source = "./primary_ip"

  amount = var.worker_count
  role   = "worker"
  domain = var.domain
}

module "workers" {
  source = "./server"

  amount            = var.worker_count
  role              = "worker"
  ssh_pub_key       = var.ssh_pub_key
  ssh_priv_key_path = var.ssh_priv_key_path
  domain            = var.domain
  ip_addresses      = module.worker_ips.addresses
  firewall_rules = {
    bgp = {
      proto = "tcp",
      ports = [179],
      cidrs = concat(
        module.worker_ips.addresses["ipv4"],
        module.worker_ips.addresses["ipv4"],
      )
    }
    vxlan = {
      proto = "udp",
      ports = [4789],
      cidrs = concat(
        module.worker_ips.addresses["ipv4"],
        module.worker_ips.addresses["ipv4"],
      )
    }
    kubelet = {
      proto = "tcp",
      ports = [10250],
      cidrs = concat(
        module.worker_ips.addresses["ipv4"],
        module.worker_ips.addresses["ipv4"],
      )
    }
    kubeproxy = {
      proto = "tcp",
      ports = [10249],
      cidrs = concat(
        module.worker_ips.addresses["ipv4"],
        module.worker_ips.addresses["ipv4"],
      )
    }
    prometheus_node_exporter = {
      proto = "tcp",
      ports = [9100],
      cidrs = concat(
        module.worker_ips.addresses["ipv4"],
        module.worker_ips.addresses["ipv4"],
      )
    }
  }
}
