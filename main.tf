# Get our API key for hetzner
provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "default" {
  name       = "hetzner"
  public_key = var.ssh_pub_key
}

module "worker_ips" {
  source = "./modules/primary_ip"

  amount = var.worker_count
  role   = "worker"
  domain = var.domain
}

module "controller_ips" {
  source = "./modules/primary_ip"

  amount = var.controller_count
  role   = "controller"
  domain = var.domain
}

module "workers" {
  source = "./modules/server"

  amount            = var.worker_count
  role              = "worker"
  ssh_pub_key_id    = hcloud_ssh_key.default.id
  ssh_priv_key_path = var.ssh_priv_key_path
  domain            = var.domain
  ip_addresses      = module.worker_ips.addresses
  firewall_rules = {
    bgp = {
      proto = "tcp",
      ports = [179],
      cidrs = concat(
        module.worker_ips.addresses["ipv6"],
        module.worker_ips.addresses["ipv4"],
      )
    }
    vxlan = {
      proto = "udp",
      ports = [4789],
      cidrs = concat(
        module.worker_ips.addresses["ipv6"],
        module.worker_ips.addresses["ipv4"],
      )
    }
    kubelet = {
      proto = "tcp",
      ports = [10250],
      cidrs = concat(
        module.worker_ips.addresses["ipv6"],
        module.worker_ips.addresses["ipv4"],
      )
    }
    kubeproxy = {
      proto = "tcp",
      ports = [10249],
      cidrs = concat(
        module.worker_ips.addresses["ipv6"],
        module.worker_ips.addresses["ipv4"],
      )
    }
    prometheus_node_exporter = {
      proto = "tcp",
      ports = [9100],
      cidrs = concat(
        module.worker_ips.addresses["ipv6"],
        module.worker_ips.addresses["ipv4"],
      )
    }
  }
}

module "controllers" {
  source = "./modules/server"

  amount            = var.controller_count
  role              = "controller"
  ssh_pub_key_id    = hcloud_ssh_key.default.id
  ssh_priv_key_path = var.ssh_priv_key_path
  domain            = var.domain
  ip_addresses      = module.controller_ips.addresses
  firewall_rules = {
    k8s-api = {
      proto = "tcp",
      ports = [6443],
      cidrs = concat(
        module.worker_ips.addresses["ipv6"],
        module.worker_ips.addresses["ipv4"],
        module.controller_ips.addresses["ipv6"],
        module.controller_ips.addresses["ipv4"],
      )
    }
    etcd = {
      proto = "tcp",
      ports = [2380],
      cidrs = concat(
        module.controller_ips.addresses["ipv6"],
        module.controller_ips.addresses["ipv4"],
      )
    }
    konnectivity = {
      proto = "tcp",
      ports = [8132, 8133],
      cidrs = concat(
        module.worker_ips.addresses["ipv6"],
        module.worker_ips.addresses["ipv4"],
      )
    }
    k0s-api = {
      proto = "tcp",
      ports = [9443],
      cidrs = concat(
        module.worker_ips.addresses["ipv6"],
        module.worker_ips.addresses["ipv4"],
        module.controller_ips.addresses["ipv6"],
        module.controller_ips.addresses["ipv4"],
      )
    }
  }
}
