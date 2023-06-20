# Docs at https://registry.terraform.io/providers/hetznercloud/hcloud/latest
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.40.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    k0s = {
      source  = "alessiodionisi/k0s"
      version = "0.1.1"
    }
  }
}
