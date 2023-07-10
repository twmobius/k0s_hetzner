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

# Worker specific variables
variable "worker_count" {
  type        = number
  description = "The number of workers. Defaults to 3"
  default     = 3
}

variable "worker_server_type" {
  type        = string
  description = "The Hetzner cloud server type. Values: cax11, cax21, cax31, cax41 (all ARM64)"
  # arm64 machine
  default = "cax11"
  validation {
    condition     = can(regex("c[apc]?x[1234]1", var.worker_server_type))
    error_message = "Unsupported server type provided"
  }
}

variable "worker_server_image" {
  type        = string
  description = "The Hetzner cloud server image. Values: debian-11, debian-12"
  default     = "debian-12"
  validation {
    condition     = can(regex("debian-1[12]", var.worker_server_image))
    error_message = "Unsupported server image provided"
  }
}

variable "worker_server_datacenter" {
  type        = string
  description = "The Hetzner datacenter name to create the server in. Values: nbg1-dc3, fsn1-dc14, hel1-dc2, ash-dc1 or hil-dc1"
  default     = "fsn1-dc14"
  validation {
    condition     = can(regex("\\w{1,}-dc[0-9]{1,}", var.worker_server_datacenter))
    error_message = "Unsupported datacenter provided"
  }
}

# Controller specific variables
variable "controller_count" {
  type        = number
  description = "The number of controllers. Defaults to 3"
  default     = 3
}

variable "controller_server_type" {
  type        = string
  description = "The Hetzner cloud server type. Values: cax11, cax21, cax31, cax41 (all ARM64)"
  # arm64 machine
  default = "cax11"
  validation {
    condition     = can(regex("c[apc]?x[1234]1", var.controller_server_type))
    error_message = "Unsupported server type provided"
  }
}

variable "controller_server_image" {
  type        = string
  description = "The Hetzner cloud server image. Values: debian-11, debian-12"
  default     = "debian-12"
  validation {
    condition     = can(regex("debian-1[12]", var.controller_server_image))
    error_message = "Unsupported server image provided"
  }
}

variable "controller_server_datacenter" {
  type        = string
  description = "The Hetzner datacenter name to create the server in. Values: nbg1-dc3, fsn1-dc14, hel1-dc2, ash-dc1 or hil-dc1"
  default     = "fsn1-dc14"
  validation {
    condition     = contains(["nbg1-dc3", "hel1-dc2", "fsn1-dc14", "ash-dc1", "hil-dc1"], var.controller_server_datacenter)
    error_message = "Unsupported datacenter provided"
  }
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

variable "single_controller_hostname" {
  type        = string
  description = "If you are deploying using a single role, it's probably a pet. Name it"
  default     = null
}

# Networking values
variable "enable_ipv4" {
  type        = bool
  description = "Whether an IPv4 address should be allocated"
  default     = true
}

variable "enable_ipv6" {
  type        = bool
  description = "Whether an IPv6 address should be allocated"
  default     = true
}
