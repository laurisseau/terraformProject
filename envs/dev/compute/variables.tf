variable "environment"{
  description = "application environment"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type = string
}

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL"
  type        = string
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "proxmox_insecure"{
  description = "provider boolean for proxmox"
  type = bool
}

variable "proxmox_vm_template_id" {
  description = "Template VM ID to clone from"
  type        = number
}

# Network Configuration
variable "network_bridge" {
  description = "Proxmox network bridge"
  type        = string
}

variable "network_model" {
  description = "Network interface model"
  type        = string
}

variable "datastore_id" {
  description = "Proxmox datastore ID"
  type        = string
}

variable "controller_vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "worker_vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "ansible_inventory_path" {
  description = "Path to Ansible inventory"
  type        = string
}

variable "ansible_playbooks_path" {
  description = "Path to Ansible playbooks"
  type        = string
}

variable "aws_secret_name" {
  description = "AWS Secrets Manager secret name"
  type        = string
}

variable "setup_controller_playbook" {
  description = "ansible playbook for dynamodb"
  type        = string
}

variable "setup_worker_playbook" {
  description = "ansible playbook for mysql"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to store SSH private keys"
  type        = string
}

variable "ssh_key_algorithm" {
  description = "SSH key algorithm"
  type        = string
}

variable "ssh_key_bits" {
  description = "SSH key bit length"
  type        = number
}

variable "aws_region" {
  description = "aws region"
  type        = string
}