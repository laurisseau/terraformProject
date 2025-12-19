resource "proxmox_virtual_environment_firewall_rules" "apply_sg_to_vms" {
  node_name       = var.proxmox_node
  vm_id           = var.vm_id
  rule {
    security_group = var.security_group_name
    comment        = "From security group ${var.security_group_name}"
    iface          = var.iface
  }
}

resource "proxmox_virtual_environment_firewall_options" "firewall_options" {

  node_name = var.proxmox_node
  vm_id     = var.vm_id

  dhcp          = false
  enabled       = true

  # LOGGING - Monitor suspicious activity
  log_level_in  = "info"    # Log dropped packets
  log_level_out = "nolog"   # Don't log normal outbound traffic
  
}

