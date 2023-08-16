variable "cluster_id" {
  type = string
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

variable "port" {
  type = number
}

variable "health_check" {
  type = object({ type = string, path = string, host = string, port = optional(number) })
}

variable "internal_vip" {
  type    = string
  default = ""
}
