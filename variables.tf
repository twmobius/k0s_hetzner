variable "hcloud_token" {
  sensitive   = true # Requires terraform >= 0.14
  description = "Value of the Hetzner token"
  type        = string
}

variable "hcloud_server_type" {
  type        = string
  description = "The Hetzner cloud server type. Values: cax11, cax21, cax31, cax41 (all ARM64)"
  default     = "cax11"
  validation {
    condition     = can(regex("cax[1234]1", var.hcloud_server_type))
    error_message = "Unsupported server type provided"
  }
}

variable "ssh_key" {
  type        = string
  description = "SSH key for connecting to servers"
}

variable "controller1_rdns" {
  type        = string
  description = "Reverse PTR"
}
