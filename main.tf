# Get our API key for hetzner
provider "hcloud" {
  token = var.hcloud_token
}

provider "helm" {
  kubernetes {
    config_path = "kubeconfig-${var.domain}"
  }
}

locals {
  controller_count  = var.controller_role == "single" ? 1 : var.controller_count
  worker_count      = var.controller_role == "single" ? 0 : var.worker_count
  create_keys       = (var.ssh_pub_key == null || var.ssh_priv_key_path == null) ? true : false
  ssh_priv_key_path = var.ssh_priv_key_path == null ? "id_ed25519_${var.domain}" : var.ssh_priv_key_path
}

# ED25519 key
resource "tls_private_key" "ed25519" {
  count     = local.create_keys ? 1 : 0
  algorithm = "ED25519"
}

resource "local_file" "ssh_priv_key_path" {
  count           = local.create_keys ? 1 : 0
  filename        = local.ssh_priv_key_path
  file_permission = "0600"
  content         = nonsensitive(one(tls_private_key.ed25519.*.private_key_openssh))
}

resource "hcloud_ssh_key" "terraform-hcloud-k0s" {
  name = "terraform-hcloud-k0s"
  # We depend on the local_file because we want it created, before we create servers
  depends_on = [local_file.ssh_priv_key_path]
  public_key = local.create_keys ? one(tls_private_key.ed25519.*.public_key_openssh) : var.ssh_pub_key
}

module "worker_ips" {
  source = "./modules/network"

  amount      = local.worker_count
  role        = "worker"
  domain      = var.domain
  enable_ipv4 = var.enable_ipv4
  enable_ipv6 = var.enable_ipv6
}

module "controller_ips" {
  source = "./modules/network"

  amount                  = local.controller_count
  role                    = "controller"
  domain                  = var.domain
  enable_ipv4             = var.enable_ipv4
  enable_ipv6             = var.enable_ipv6
  enable_balancer         = var.balance_control_plane
  enable_network          = var.enable_private_network
  network_ip_range        = var.network_ip_range
  network_subnet_type     = var.network_subnet_type
  network_subnet_ip_range = var.network_subnet_ip_range
  network_vswitch_id      = var.network_vswitch_id
  network_zone            = var.network_zone
}

locals {
  worker_cidrs = compact(concat(
    module.worker_ips.addresses["ipv6cidr"],
    module.worker_ips.addresses["ipv4cidr"],
    var.enable_private_network ? [var.network_subnet_ip_range] : [],
    var.controller_role == "controller+worker" ? concat(
      module.controller_ips.addresses["ipv6cidr"],
    module.controller_ips.addresses["ipv4cidr"]) : []
  ))
  controller_cidrs = compact(concat(
    module.controller_ips.addresses["ipv6cidr"],
    module.controller_ips.addresses["ipv4cidr"],
    var.enable_private_network ? [var.network_subnet_ip_range] : [],
  ))
  base_rules = {
    icmp = {
      proto = "icmp",
      port  = null,
      cidrs = [
        "0.0.0.0/0",
        "::/0",
      ],
    }
    ssh = {
      proto = "tcp",
      port  = "22",
      cidrs = [
        "0.0.0.0/0",
        "::/0",
      ],
    }
  }
  base_worker_firewall_rules = {
    bgp = {
      proto = "tcp",
      port  = "179",
      cidrs = local.worker_cidrs,
    }
    vxlan = {
      proto = "udp",
      port  = "4789",
      cidrs = local.worker_cidrs,
    }
    kubelet = {
      proto = "tcp",
      port  = "10250",
      cidrs = local.worker_cidrs,
    }
    kubeproxy = {
      proto = "tcp",
      port  = "10249",
      cidrs = local.worker_cidrs,
    }
    prometheusnodeexporter = {
      proto = "tcp",
      port  = "9100",
      cidrs = local.worker_cidrs,
    }
  }
  base_controller_firewall_rules = {
    k8s-api = {
      proto = "tcp",
      port  = "6443",
      cidrs = [
        "0.0.0.0/0",
        "::/0",
      ],
    }
    etcd = {
      proto = "tcp",
      port  = "2380",
      cidrs = local.controller_cidrs,
    }
    # Konnectivity is only accessed from workers
    konnectivity = {
      proto = "tcp",
      port  = "8132-8133",
      cidrs = local.worker_cidrs,
    }
    k0s-api = {
      proto = "tcp",
      port  = "9443",
      cidrs = toset(concat(local.worker_cidrs, local.controller_cidrs)),
    }
  }
  # If the controller role is "controller+worker" then we are going to rely exclusively on Calico HostEndpoints
  controller_firewall_rules = (
    var.controller_role == "controller+worker" ? {} :
    merge(local.base_rules, local.base_controller_firewall_rules)
  )
  worker_firewall_rules = (
    var.controller_role == "controller+worker" ?
    merge(local.base_rules, local.base_controller_firewall_rules, local.base_worker_firewall_rules) :
    merge(local.base_rules, local.base_worker_firewall_rules)
  )
}

module "workers" {
  source = "./modules/server"

  amount            = local.worker_count
  type              = var.worker_server_type
  image             = var.worker_server_image
  datacenter        = var.worker_server_datacenter
  role              = "worker"
  ssh_pub_key_id    = hcloud_ssh_key.terraform-hcloud-k0s.id
  ssh_priv_key_path = local.ssh_priv_key_path
  domain            = var.domain
  ip_address_ids    = module.worker_ips.address_ids
  enable_network    = var.enable_private_network
  network_subnet_id = module.controller_ips.subnet_id
}

module "controllers" {
  source = "./modules/server"

  amount            = local.controller_count
  type              = var.controller_server_type
  image             = var.controller_server_image
  datacenter        = var.controller_server_datacenter
  role              = var.controller_role
  ssh_pub_key_id    = hcloud_ssh_key.terraform-hcloud-k0s.id
  ssh_priv_key_path = local.ssh_priv_key_path
  domain            = var.domain
  hostname          = var.single_controller_hostname
  ip_address_ids    = module.controller_ips.address_ids
  enable_network    = var.enable_private_network
  network_subnet_id = module.controller_ips.subnet_id
  firewall_rules    = local.controller_firewall_rules
}

# This is the first module where we can refer to IP addresses from the output
# of the server module and not the network module. This is because we now have
# the data from the server module
#
locals {
  externalIPs = (var.controller_role == "single" || var.controller_role == "controller+worker") ? flatten(
    [
      for _, addresses in module.controllers.addresses :
      compact(values(addresses))
    ]
    ) : flatten(
    [
      for _, addresses in module.workers.addresses :
      compact(values(addresses))
    ]
  )

  worker_addresses = merge(module.workers.addresses, var.extra_workers)
  hccm_enable      = length(var.extra_workers) > 0 ? false : var.hccm_enable
}
module "k0s" {
  source = "./modules/k0s"

  domain               = var.domain
  controller_role      = var.controller_role
  hcloud_token         = var.hcloud_token
  hccm_enable          = local.hccm_enable
  hcsi_enable          = var.hcsi_enable
  hcsi_encryption_key  = var.hcsi_encryption_key
  prometheus_enable    = var.prometheus_enable
  ssh_priv_key_path    = local.ssh_priv_key_path
  controller_addresses = module.controllers.addresses
  worker_addresses     = local.worker_addresses
  firewall_rules       = local.worker_firewall_rules

  cp_balancer_ips = concat(
    module.controller_ips.lb_addresses["ipv4"],
    module.controller_ips.lb_addresses["ipv6"],
  )
  externalIPs = local.externalIPs
}
