# SSH Key Generation
resource "tls_private_key" "contoller_ssh" {
  algorithm = var.ssh_key_algorithm
  rsa_bits  = var.ssh_key_bits
}

resource "tls_private_key" "worker_ssh" {
  algorithm = var.ssh_key_algorithm
  rsa_bits  = var.ssh_key_bits
}

# Save SSH Private Keys
resource "local_file" "controller_private_key" {
  filename        = local.ssh_key_paths.controller
  content         = tls_private_key.contoller_ssh.private_key_pem
  file_permission = "0600"
}

resource "local_file" "worker_private_key" {
  filename        = local.ssh_key_paths.worker
  content         = tls_private_key.worker_ssh.private_key_pem
  file_permission = "0600"
}

# Controller VM
module "controller_vm" {
  source = "../../../modules/compute/vm"

  vm_name        = local.vms.controller.name
  vm_ram         = "4096"
  vm_cpu         = 2
  vm_disk_size   = 40
  vm_description = local.vms.controller.description
  vm_tags        = concat(local.vms.controller.tags, ["development"])
  ssh_public_key = tls_private_key.contoller_ssh.public_key_openssh
  user_password  = local.vms.controller.password
  username       = local.vms.controller.username
  
  # Configuration
  proxmox_node    = var.proxmox_node
  proxmox_vm_template_id = var.proxmox_vm_template_id
  datastore_id  = var.datastore_id
  network_bridge = var.network_bridge
  network_model = var.network_model

  aws_region = var.aws_region
  environment = var.environment
  aws_secret_name = var.aws_secret_name
  project_name = var.project_name
}

# Worker VM
module "worker_vm" {
  source = "../../../modules/compute/vm"

  vm_name        = local.vms.worker.name
  vm_ram         = "4096"
  vm_cpu         = 2
  vm_disk_size   = 40
  vm_description = local.vms.worker.description
  vm_tags        = concat(local.vms.worker.tags, ["development"])
  ssh_public_key = tls_private_key.worker_ssh.public_key_openssh
  user_password  = local.vms.worker.password
  username       = local.vms.worker.username
  
  # Configuration
  proxmox_node    = var.proxmox_node
  proxmox_vm_template_id = var.proxmox_vm_template_id
  datastore_id  = var.datastore_id
  network_bridge = var.network_bridge
  network_model = var.network_model

  aws_region = var.aws_region
  environment = var.environment
  aws_secret_name = var.aws_secret_name
  project_name = var.project_name
}

resource "time_sleep" "wait_for_90s" {
  depends_on = [
    module.controller_vm,
    module.worker_vm
  ]
  
  create_duration = "90s"  # Wait 90 seconds
}

# Generate Ansible Inventory
resource "local_file" "ansible_inventory" {
  depends_on = [time_sleep.wait_for_90s]

  filename = var.ansible_inventory_path

  content = templatefile("${path.module}/ansible/inventories/templates/inventory.tpl", {
    environment   = var.environment
    controller_ip   = module.controller_vm.ip_address
    worker_ip      = module.worker_vm.ip_address
    controller_user = local.vms.controller.username
    worker_user    = local.vms.worker.username
  })
}

# Run Ansible Playbooks
resource "null_resource" "ansible_provisioner" {
  depends_on = [
    local_file.ansible_inventory,
    local_file.controller_private_key,
    local_file.worker_private_key
  ]

  triggers = {
    controller_ip = module.controller_vm.ip_address
    worker_ip    = module.worker_vm.ip_address
    inventory   = md5(local_file.ansible_inventory.content)
  }

  # Controller Provisioning
  provisioner "local-exec" {
    command = "cd ${path.module}/ansible && echo 'Provisioning Controller on ${module.controller_vm.ip_address}...' && ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_FORCE_COLOR=true ansible-playbook -i inventories/inventory.ini -u ${local.vms.controller.username} --private-key ${local.ssh_key_paths.controller} --limit ${local.vms.controller.username} playbooks/${var.setup_controller_playbook}.yml"
  }

  # Worker Provisioning
  provisioner "local-exec" {
    command = "cd ${path.module}/ansible && echo 'Provisioning Worker on ${module.worker_vm.ip_address}...' && ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_FORCE_COLOR=true ansible-playbook -i inventories/inventory.ini -u ${local.vms.worker.username} --private-key ${local.ssh_key_paths.worker} --limit ${local.vms.worker.username} playbooks/${var.setup_worker_playbook}.yml"
  }
}