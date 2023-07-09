variable "amount" {
  type        = number
  description = "The number of servers"
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

variable "ip_addresses" {
  type        = map(list(string))
  description = "A map of AF_INET family and list of addresses"
}

variable "type" {
  type        = string
  description = "The Hetzner cloud server type. Defaults to cax11"
  # arm64 machine
  default = "cax11"
  validation {
    condition     = can(regex("c[apc]?x[1234]1", var.type))
    error_message = "Unsupported server type provided"
  }
}

variable "image" {
  type        = string
  description = "The Hetzner cloud server image. Values: debian-11, debian-12. Defaults to debian-12"
  default     = "debian-12"
  validation {
    condition     = can(regex("debian-1[12]", var.image))
    error_message = "Unsupported server image provided"
  }
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

variable "hostname" {
  type        = string
  description = "You can override the generated name to one of your choose. Only use if spawning up a single server"
  default     = null
}

variable "firewall_rules" {
  type = map(object({
    proto = string
    ports = list(number)
    cidrs = list(string)
  }))
  default = {
    k8s-api = { proto = "tcp", ports = [6443], cidrs = ["0.0.0.0/0"] }
  }
}
