provider "helm" {
  kubernetes {
    config_path = "kubeconfig"
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
}
