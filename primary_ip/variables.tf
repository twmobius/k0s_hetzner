variable "amount" {
  type        = number
  description = "The number of servers"
}

variable "role" {
  type        = string
  description = "The role of the server. It will be set in labels"
  validation {
    condition     = can(regex("(worker|controller|controller+worker|single)", var.role))
    error_message = "Unsupported server role provided"
  }
}

variable "domain" {
  type        = string
  description = "The domain of all hosts. Will be used to generate all PTRs"
}

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

variable "datacenter" {
  type        = string
  description = "The Hetzner datacenter name to create the server in. Values: nbg1-dc3, fsn1-dc14, hel1-dc2, ash-dc1, hil-dc1. Defaults to fsn1-dc14"
  default     = "fsn1-dc14"
  validation {
    condition     = contains(["nbg1-dc3", "fsn1-dc14", "hel1-dc2", "ash-dc1", "hil-dc1"], var.datacenter)
    error_message = "Unsupported datacenter provided"
  }
}
