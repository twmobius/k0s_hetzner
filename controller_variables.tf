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
    condition     = can(regex("cax[1234]1", var.controller_server_type))
    error_message = "Unsupported server type provided"
  }
}

variable "controller_server_image" {
  type        = string
  description = "The Hetzner cloud server image. Values: debian-11, debian-12"
  # TODO: Bump to 12 once it's available
  default = "debian-11"
  validation {
    condition     = can(regex("debian-1[12]", var.controller_server_image))
    error_message = "Unsupported server image provided"
  }
}

variable "controller_server_location" {
  type        = string
  description = "The Hetzner cloud server location. Values: fsn1"
  # Only falkenstein has arm64 for now
  default = "fsn1"
  validation {
    condition     = can(regex("fsn1", var.controller_server_location))
    error_message = "Unsupported server location provided"
  }
}

variable "controller_role" {
  type        = string
  description = "The k0s role for a controller. Values: controller, controller+worker"
  default     = "controller"
  validation {
    condition     = can(regex("controller|controller+worker", var.controller_role))
    error_message = "Unsupported controller role"
  }
}
