variable "domain" {
  type        = string
  description = "The domain of all hosts. Will be used to generate all PTRs and names"
}

variable "ssh_priv_key_path" {
  type        = string
  description = "The private part of the above"
  sensitive   = true
}

variable "k0s_version" {
  type        = string
  description = "The version of k0s to target. Default: 1.27.4+k0s.0"
  default     = "1.27.4+k0s.0"
  validation {
    condition     = can(regex("1.27.[234]\\+k0s\\.0", var.k0s_version))
    error_message = "Unsupported k0s version provided"
  }
}

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

variable "prometheus_enable" {
  type        = bool
  description = "Whether to enable the entire prometheus stack"
  default     = true
}

variable "externalIPs" {
  type        = list(string)
  description = "Ingress-nginxs externalIPs setting. Needs to match at least the IPs of the workers"
  default     = []
}

variable "controller_role" {
  type        = string
  description = "The k0s role for a controller. Values: controller, controller+worker, single"
  default     = "controller"
  validation {
    condition     = can(regex("controller|controller+worker|single", var.controller_role))
    error_message = "Unsupported controller role"
  }
}

variable "cp_balancer_ips" {
  type        = list(string)
  description = "If balancing the control-plane, its IPs"
  default     = []
}

variable "controller_addresses" {
  type = map(object({
    public_ipv4  = optional(string),
    public_ipv6  = optional(string),
    private_ipv4 = optional(string),
  }))
  description = "A map of objects containing IPv4/IPv6 public and private addresses"
}

variable "worker_addresses" {
  type = map(object({
    public_ipv4  = optional(string),
    public_ipv6  = optional(string),
    private_ipv4 = optional(string),
  }))
  description = "A map of objects containing IPv4/IPv6 public and private addresses. Defaults to empty map"
  default     = {}
}

variable "firewall_rules" {
  type = map(object({
    proto = string
    port  = string
    cidrs = list(string)
  }))
  description = "A map of firewall holes. The keys are arbitrary strings, the values objects with proto, ports, cidrs keys"
  default     = {}
}
