variable "hcloud_token" {
  sensitive   = true # Requires terraform >= 0.14
  description = "Value of the Hetzner token"
  type        = string
}

variable "hcloud_server_type" {
  type        = string
  description = "The Hetzner cloud server type. Values: cax11, cax21, cax31, cax41 (all ARM64)"
  # arm64 machine
  default = "cax11"
  validation {
    condition     = can(regex("cax[1234]1", var.hcloud_server_type))
    error_message = "Unsupported server type provided"
  }
}

variable "hcloud_server_image" {
  type        = string
  description = "The Hetzner cloud server image. Values: debian-11, debian-12"
  # TODO: Bump to 12 once it's available
  default = "debian-11"
  validation {
    condition     = can(regex("debian-1[12]", var.hcloud_server_image))
    error_message = "Unsupported server image provided"
  }
}

variable "hcloud_server_location" {
  type        = string
  description = "The Hetzner cloud server location. Values: fsn1"
  default     = "fsn1"
  # Only falkenstein has arm64 for now
  validation {
    condition     = can(regex("fsn1", var.hcloud_server_location))
    error_message = "Unsupported server location provided"
  }
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

variable "controller_count" {
  type        = number
  description = "The number of controllers. Defaults to 3"
  default     = 3
}
