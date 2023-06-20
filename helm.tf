provider "helm" {
  kubernetes {
    config_path = "kubeconfig"
  }
}

resource "helm_release" "cert-manager" {
  depends_on = [
    k0s_cluster.k0s1
  ]
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
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
    k0s_cluster.k0s1
  ]
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.7.0"

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }
}
