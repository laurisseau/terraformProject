resource "proxmox_virtual_environment_vm" "this" {
  name        = var.vm_name
  description = var.vm_description
  tags        = concat(["terraform"], var.vm_tags)
  node_name   = var.proxmox_node

  clone {
    vm_id     = var.proxmox_vm_template_id
    node_name = var.proxmox_node
    retries   = 2
  }

  cpu {
    cores   = var.vm_cpu
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = var.vm_ram
  }

  disk {
    interface    = "scsi0"
    datastore_id = var.datastore_id
    size         = var.vm_disk_size
  }

  network_device {
    bridge = var.network_bridge
    model  = var.network_model
  }

  initialization {
    datastore_id = var.datastore_id
    
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      username = var.username
      password = var.user_password
      keys     = [var.ssh_public_key]
    }
  }

  agent {
    enabled = true
    trim    = true
    type    = var.network_model
  }

  lifecycle {
    ignore_changes = [
      clone[0].vm_id,
      disk,
      tags,
      initialization[0].user_account[0].keys
    ]
  }
}