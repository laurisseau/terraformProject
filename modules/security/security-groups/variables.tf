variable "proxmox_node" {
  type = string
}

variable "security_group_name" {
  type = string
}

variable "rules" {
  type = list(object({
    type    = string
    action  = string
    comment = string
    source  = string
    dport   = optional(string)
    sport   = optional(string)
    proto   = optional(string, "tcp")
    enable  = optional(number, 1)
  }))
  default = []
}

variable "aws_region"{
  type = string
}

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "aws_secret_name" {
  type = string
}