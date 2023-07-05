resource "hcloud_load_balancer" "cp_load_balancer" {
  count              = var.controller_role == "single" ? 0 : 1
  name               = "control-plane-balancer"
  load_balancer_type = var.controller_load_balancer_type
  location           = var.controller_server_location
  algorithm {
    type = "round_robin"
  }
}

resource "hcloud_load_balancer_service" "cp_load_balancer_kubernetes_service" {
  count            = var.controller_role == "single" ? 0 : 1
  depends_on       = [hcloud_load_balancer.cp_load_balancer]
  load_balancer_id = hcloud_load_balancer.cp_load_balancer[0].id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
}

resource "hcloud_load_balancer_service" "cp_load_balancer_konnectivity_service" {
  count            = var.controller_role == "single" ? 0 : 1
  depends_on       = [hcloud_load_balancer.cp_load_balancer]
  load_balancer_id = hcloud_load_balancer.cp_load_balancer[0].id
  protocol         = "tcp"
  listen_port      = 8132
  destination_port = 8132
}

resource "hcloud_load_balancer_service" "cp_load_balancer_controller_api_service" {
  count            = var.controller_role == "single" ? 0 : 1
  depends_on       = [hcloud_load_balancer.cp_load_balancer]
  load_balancer_id = hcloud_load_balancer.cp_load_balancer[0].id
  protocol         = "tcp"
  listen_port      = 9443
  destination_port = 9443
}

resource "hcloud_load_balancer_target" "cp_load_balancer_target" {
  count            = var.controller_role == "single" ? 0 : var.controller_count
  type             = "server"
  depends_on       = [hcloud_load_balancer.cp_load_balancer]
  load_balancer_id = hcloud_load_balancer.cp_load_balancer[0].id
  server_id        = hcloud_server.controller[count.index].id
}

resource "hcloud_rdns" "cp_load_balancer_ipv4" {
  count            = var.controller_role == "single" ? 0 : 1
  load_balancer_id = hcloud_load_balancer.cp_load_balancer[0].id
  ip_address       = hcloud_load_balancer.cp_load_balancer[0].ipv4
  dns_ptr          = format("%s.%s", "cp-bl", var.domain)
}

resource "hcloud_rdns" "cp_load_balancer_ipv6" {
  count            = var.controller_role == "single" ? 0 : 1
  load_balancer_id = hcloud_load_balancer.cp_load_balancer[0].id
  ip_address       = hcloud_load_balancer.cp_load_balancer[0].ipv6
  dns_ptr          = format("%s.%s", "cp-bl", var.domain)
}
