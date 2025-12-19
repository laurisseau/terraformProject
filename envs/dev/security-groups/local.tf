locals {

  database_vms = {
    
    "firewall" = "db_firewall"

    "mysql" = {
      vm_id = 100
      proxmox_node  = "pve"
    }
    "dynamodb" = {
      vm_id = 101
      proxmox_node  = "pve"
    }
  }


  web_server_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "SSH from management"
      source  = "10.0.1.0/24"
      dport   = "22"
    },
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "HTTP"
      source  = "0.0.0.0/0"
      dport   = "80"
    },
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "HTTPS"
      source  = "0.0.0.0/0"
      dport   = "443"
    },
    {
      type    = "in"
      action  = "DROP"
      comment = "Default deny"
      source  = "0.0.0.0/0"
      proto   = "tcp"
    }
  ]

  database_server_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "DynamoDB port"
      source  = "192.168.1.0/24"
      dport   = "8000"
    },
    {
      type    = "in"
      action  = "ACCEPT"
      comment = "MySQL port"
      source  = "192.168.1.0/24"
      dport   = "3306"
    }
  ]


}