variable "hcloud_token" {
  type        = string
  sensitive   = true # Requires terraform >= 0.14
  description = "Value of the Hetzner token"
}

variable "hccm_enable" {
  type        = bool
  description = "Whether or not the Hetzner Cloud controller manager will be installed"
  default     = true
}

variable "hcsi_enable" {
  type        = bool
  description = "Whether or not the Hetzner CSI (Cloud Storage Interface) will be installed"
  default     = true
}

variable "hcsi_encryption_key" {
  type        = string
  description = "If specified, a Kubernetes StorageClass with LUKS encryption will become available"
  default     = ""
}


variable "balance_control_plane" {
  type        = bool
  description = "Whether the control plane will be load balanced. Needs > 1 controller"
  default     = false
}

variable "prometheus_enable" {
  type        = bool
  description = "Whether to enable the entire prometheus stack"
  default     = true
}

variable "ssh_pub_key" {
  type        = string
  description = "Public SSH key for connecting to servers"
}

variable "ssh_priv_key_path" {
  type        = string
  description = "The private part of the above"
  sensitive   = true
}

variable "domain" {
  type        = string
  description = "The domain of all hosts. Will be used to generate all PTRs"
}

variable "k0s_version" {
  type        = string
  description = "The version of k0s to target. Default: 1.27.2+k0s.0"
  default     = "1.27.2+k0s.0"
  validation {
    condition     = can(regex("1.27.2\\+k0s\\.0", var.k0s_version))
    error_message = "Unsupported k0s version provided"
  }
}
