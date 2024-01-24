variable "cluster_id" {
  type = string
}

variable "lb_flavor" {
  type    = string
  default = "lb-standard"
}

variable "role" {
  type = string
}

variable "region" {
  type = string
}

variable "protocol" {
  type = string
}

variable "subnet_uuid" {
  type = string
}

variable "members" {
  type = list(string)
}

variable "bootstrap_ip" {
  type    = string
  default = ""
}

variable "ports" {
  type = list(number)
}

variable "health_check" {
  type = object({ type = string, path = string, host = string, port = optional(number) })
}

variable "internal_vip" {
  type    = string
  default = ""
}

variable "allowed_cidrs" {
  type    = map(list(string))
  default = {}
}
