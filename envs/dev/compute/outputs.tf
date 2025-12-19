output "vm_summary" {
  description = "Summary of all provisioned VMs"
  value = {
    controller = {
      name        = module.controller_vm.name
      id          = module.controller_vm.id
      ip_address  = module.controller_vm.ip_address
      ssh_command = "ssh -i ${local.ssh_key_paths.controller} ${local.vms.controller.username}@${module.controller_vm.ip_address}"
      ssh_user    = local.vms.controller.username
    }
    worker = {
      name        = module.worker_vm.name
      id          = module.worker_vm.id
      ip_address  = module.worker_vm.ip_address
      ssh_command = "ssh -i ${local.ssh_key_paths.worker} ${local.vms.worker.username}@${module.worker_vm.ip_address}"
      ssh_user    = local.vms.worker.username
    }
  }
}

/*
output "ssh_key_info" {
  description = "SSH key information (sensitive)"
  value = {
    controller_private_key_path = local.ssh_key_paths.controller
    worker_private_key_path    = local.ssh_key_paths.worker
    controller_public_key       = sensitive(tls_private_key.controller_ssh.public_key_openssh)
    worker_public_key          = sensitive(tls_private_key.worker_ssh.public_key_openssh)
  }
  sensitive = true
}
*/