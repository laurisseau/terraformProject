resource "proxmox_virtual_environment_cluster_firewall_security_group" "security_group" {
  name = var.security_group_name
  dynamic "rule" {
    for_each = var.rules
    content {
      type    = rule.value.type
      action  = rule.value.action
      comment = rule.value.comment
      source  = rule.value.source
      dport   = rule.value.dport
      sport   = rule.value.sport
      proto   = rule.value.proto
      enabled  = true
    }
  }
}


