variable "vm_name" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "proxmox_vm_template_id" {
  type = number
}

variable "network_bridge" {
  type = string 
}

variable "network_model" {
  type = string
}

variable "datastore_id" {
  type = string
}

variable "vm_cpu" {
  type = string
}

variable "vm_ram" {
  type = string
}

variable "vm_disk_size"{
    type = string
}

variable "vm_description" {
  type = string
}

variable "vm_tags" {
  type    = list(string)
  default = []
}

variable "ssh_public_key" {
  type = string
}

variable "user_password" {
  type      = string
  sensitive = true
}

variable "username" {
  type = string
}

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_secret_name" {
  type = string
}