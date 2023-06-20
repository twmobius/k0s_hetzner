output "kubeconfig" {
  value = nonsensitive(k0s_cluster.k0s1.kubeconfig)
}
