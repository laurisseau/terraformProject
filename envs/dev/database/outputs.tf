output "vm_summary" {
  description = "Summary of all provisioned VMs"
  value = {
    dynamodb = {
      name        = module.dynamodb_vm.name
      id          = module.dynamodb_vm.id
      ip_address  = module.dynamodb_vm.ip_address
      ssh_command = "ssh -i ${local.ssh_key_paths.dynamodb} ${local.vms.dynamodb.username}@${module.dynamodb_vm.ip_address}"
      ssh_user    = local.vms.dynamodb.username
    }
    mysql = {
      name        = module.mysql_vm.name
      id          = module.mysql_vm.id
      ip_address  = module.mysql_vm.ip_address
      ssh_command = "ssh -i ${local.ssh_key_paths.mysql} ${local.vms.mysql.username}@${module.mysql_vm.ip_address}"
      ssh_user    = local.vms.mysql.username
    }
  }
}

output "ssh_key_info" {
  description = "SSH key information (sensitive)"
  value = {
    dynamodb_private_key_path = local.ssh_key_paths.dynamodb
    mysql_private_key_path    = local.ssh_key_paths.mysql
    dynamodb_public_key       = sensitive(tls_private_key.dynamodb_ssh.public_key_openssh)
    mysql_public_key          = sensitive(tls_private_key.mysql_ssh.public_key_openssh)
  }
  sensitive = true
}

/*
output "ansible_inventory_generated" {
  description = "Whether Ansible inventory was generated"
  value       = local_file.ansible_inventory.filename != ""
}


output "provisioning_status" {
  description = "Provisioning status"
  value       = "VMs created and Ansible provisioning triggered. Check null_resource.ansible_provisioner for details."
}

*/