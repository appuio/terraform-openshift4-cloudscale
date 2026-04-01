variable "create" {
  type        = bool
  default     = true
  description = "Whether to create the LB defined by the module instance"
}

variable "cluster_id" {
  type        = string
  description = "The Project Syn cluster ID"
}

variable "lb_flavor" {
  type        = string
  default     = "lb-standard"
  description = "The cloudscale LBaaS flavor"
}

variable "role" {
  type = string
}

variable "region" {
  type = string
}

variable "protocol" {
  type        = string
  description = "The protocol for the LB listeners"
  validation {
    condition     = var.protocol == "tcp" || var.protocol == "udp"
    error_message = "LB protocol must be 'tcp' or 'udp'"
  }
}

variable "subnet_uuid" {
  type        = string
  description = "The subnet UUID for the listeners and internal VIP"
}

variable "members" {
  type        = list(string)
  description = "The IP addresses of the pool members"
}

variable "bootstrap_ip" {
  type        = string
  default     = ""
  description = "The IP of the OpenShift bootstrap node. Configured as a separate pool member to avoid LB recreation when the bootstrap node is removed."
}

variable "ports" {
  type        = list(number)
  description = "The ports to configure on the listener and pool members. Currently the module expects that listener and pool member ports are a 1:1 mapping."
}

variable "health_check" {
  type        = object({ type = string, path = string, host = string, port = optional(number) })
  description = "The health check configuration for the pool members"
}

variable "internal_vip" {
  type        = string
  default     = ""
  description = "If set, the listener is configured with this IP in the given subnet instead of a public IP."
}

variable "allowed_cidrs" {
  type        = map(list(string))
  default     = {}
  description = "A map from listener port to a list of CIDRs allowed to access that port"
}
