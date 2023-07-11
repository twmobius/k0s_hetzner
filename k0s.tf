# k0s resource to create a cluster and store a kubeconfig file
resource "k0s_cluster" "k0s1" {
  depends_on = [
    module.workers,
    module.controllers,
  ]
  name    = var.domain
  version = var.k0s_version
  config = templatefile("templates/k0s.tftpl", {
    controller_lb_address = join(" ", concat(
      module.controller_ips.lb_addresses["ipv4"],
      module.controller_ips.lb_addresses["ipv6"],
    )),
    controller_ip_addresses = concat(
      module.controller_ips.addresses["ipv4"],
      module.controller_ips.addresses["ipv6"],
    )
  })
  hosts = concat(
    [
      for address in module.controller_ips.addresses["ipv4"] :
      {
        role        = var.controller_role
        no_taints   = var.controller_role == "controller+worker" ? true : false
        environment = { "ROLE" = var.controller_role }
        install_flags = [
          "--enable-metrics-scraper",
        ]
        ssh = {
          address  = address
          port     = 22
          user     = "root"
          key_path = var.ssh_priv_key_path
        }
      }
    ],
    [
      for address in module.worker_ips.addresses["ipv4"] :
      {
        role        = "worker"
        environment = { "ROLE" = "worker" }
        install_flags = var.hccm_enable ? [
          "--enable-cloud-provider",
          "--kubelet-extra-args=\"--cloud-provider=external\""
        ] : []
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

resource "local_file" "kubeconfig" {
  filename        = "kubeconfig-${var.domain}"
  file_permission = "0600"
  content         = nonsensitive(k0s_cluster.k0s1.kubeconfig)
}
