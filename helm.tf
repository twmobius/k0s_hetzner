# Note: don't go overboard adding helm charts in this file. It is meant just
# for infrastructural stuff, not generic applications
provider "helm" {
  kubernetes {
    config_path = "kubeconfig-${var.domain}"
  }
}

resource "helm_release" "cert-manager" {
  depends_on = [
    k0s_cluster.k0s1,
    local_file.kubeconfig
  ]
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "kube-system"
  version    = "1.12.0"

  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "prometheus.enabled"
    value = "false"
  }
}

resource "helm_release" "ingress-nginx" {
  depends_on = [
    k0s_cluster.k0s1,
    local_file.kubeconfig
  ]
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"
  version    = "4.7.0"

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }
  set_list {
    name = "controller.service.externalIPs"
    value = var.controller_role == "single" ? concat(
      hcloud_server.controller.*.ipv4_address,
      hcloud_server.controller.*.ipv6_address) : concat(
      hcloud_server.worker.*.ipv4_address,
      hcloud_server.worker.*.ipv6_address,
    )
  }
}

resource "terraform_data" "hcloud_token" {
  count = var.hccm_enable ? 1 : 0
  depends_on = [
    k0s_cluster.k0s1,
    local_file.kubeconfig,
  ]
  provisioner "local-exec" {
    command    = "kubectl --kubeconfig=kubeconfig-${var.domain} -n kube-system create secret generic hcloud --from-literal=token=${var.hcloud_token}"
    on_failure = continue
  }
}

resource "helm_release" "hccm" {
  count = var.hccm_enable ? 1 : 0
  depends_on = [
    k0s_cluster.k0s1,
    local_file.kubeconfig,
    terraform_data.hcloud_token,
  ]
  name       = "hccm"
  repository = "https://charts.hetzner.cloud"
  chart      = "hcloud-cloud-controller-manager"
  namespace  = "kube-system"
  version    = "1.16.0"

}
