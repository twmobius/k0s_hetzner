variable "hcloud_token" {
  sensitive   = true # Requires terraform >= 0.14
  description = "Value of the Hetzner token"
  type        = string
}

variable "ssh_key" {
  type        = string
  description = "SSH key for connecting to servers"
}
