locals {
  cp_balancer_enable           = (var.controller_role == "single" || !var.balance_control_plane) ? 0 : 1
  cp_balanced_controller_count = local.cp_balancer_enable == 0 ? 0 : var.controller_count
}

resource "hcloud_load_balancer" "cp_load_balancer" {
  count              = local.cp_balancer_enable
  name               = "control-plane-balancer"
  load_balancer_type = var.controller_load_balancer_type
  location           = var.controller_server_location
  algorithm {
    type = "round_robin"
  }
}

resource "hcloud_load_balancer_service" "cp_load_balancer_kubernetes_service" {
  count            = local.cp_balancer_enable
  load_balancer_id = hcloud_load_balancer.cp_load_balancer[0].id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
}

resource "hcloud_load_balancer_service" "cp_load_balancer_konnectivity_service" {
  count            = local.cp_balancer_enable
  load_balancer_id = hcloud_load_balancer.cp_load_balancer[0].id
  protocol         = "tcp"
  listen_port      = 8132
  destination_port = 8132
}

resource "hcloud_load_balancer_service" "cp_load_balancer_controller_api_service" {
  count            = local.cp_balancer_enable
  load_balancer_id = hcloud_load_balancer.cp_load_balancer[0].id
  protocol         = "tcp"
  listen_port      = 9443
  destination_port = 9443
}

resource "hcloud_load_balancer_target" "cp_load_balancer_target" {
  count            = local.cp_balanced_controller_count
  type             = "server"
  load_balancer_id = hcloud_load_balancer.cp_load_balancer[0].id
  server_id        = hcloud_server.controller[count.index].id
}

resource "hcloud_rdns" "cp_load_balancer_ipv4" {
  count            = local.cp_balancer_enable
  load_balancer_id = hcloud_load_balancer.cp_load_balancer[0].id
  ip_address       = hcloud_load_balancer.cp_load_balancer[0].ipv4
  dns_ptr          = format("%s.%s", "cp-bl", var.domain)
}

resource "hcloud_rdns" "cp_load_balancer_ipv6" {
  count            = local.cp_balancer_enable
  load_balancer_id = hcloud_load_balancer.cp_load_balancer[0].id
  ip_address       = hcloud_load_balancer.cp_load_balancer[0].ipv6
  dns_ptr          = format("%s.%s", "cp-bl", var.domain)
}
