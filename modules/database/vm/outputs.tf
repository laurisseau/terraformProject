output "id" {
  description = "VM ID"
  value       = proxmox_virtual_environment_vm.this.id
}

output "name" {
  description = "VM name"
  value       = proxmox_virtual_environment_vm.this.name
}

output "ip_address" {
  description = "VM IP address"
  value       = try(proxmox_virtual_environment_vm.this.ipv4_addresses[1][0], null)
}

output "ssh_connection" {
  description = "SSH connection string"
  value       = "${var.username}@${try(proxmox_virtual_environment_vm.this.ipv4_addresses[1][0], "N/A")}"
  sensitive   = false
}
