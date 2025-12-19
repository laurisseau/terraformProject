resource "proxmox_virtual_environment_firewall_rules" "apply_sg_to_vms" {
  node_name       = var.proxmox_node
  vm_id           = var.vm_id
  rule {
    security_group = var.security_group_name
    comment        = "From security group ${var.security_group_name}"
  }
}

