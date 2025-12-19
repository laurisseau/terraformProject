

# SSH Key Generation
resource "tls_private_key" "dynamodb_ssh" {
  algorithm = var.ssh_key_algorithm
  rsa_bits  = var.ssh_key_bits
}

resource "tls_private_key" "mysql_ssh" {
  algorithm = var.ssh_key_algorithm
  rsa_bits  = var.ssh_key_bits
}

# Save SSH Private Keys
resource "local_file" "dynamodb_private_key" {
  filename        = local.ssh_key_paths.dynamodb
  content         = tls_private_key.dynamodb_ssh.private_key_pem
  file_permission = "0600"
}

resource "local_file" "mysql_private_key" {
  filename        = local.ssh_key_paths.mysql
  content         = tls_private_key.mysql_ssh.private_key_pem
  file_permission = "0600"
}

# DynamoDB VM
module "dynamodb_vm" {
  source = "../../../modules/compute/vm"

  vm_name        = local.vms.dynamodb.name
  vm_ram         = "2084"
  vm_cpu         = 1
  vm_disk_size   = 32
  vm_description = local.vms.dynamodb.description
  vm_tags        = concat(local.vms.dynamodb.tags, ["development"])
  ssh_public_key = tls_private_key.dynamodb_ssh.public_key_openssh
  user_password  = local.vms.dynamodb.password
  username       = local.vms.dynamodb.username
  
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

# MySQL VM
module "mysql_vm" {
  source = "../../../modules/compute/vm"

  vm_name        = local.vms.mysql.name
  vm_ram         = "2084"
  vm_cpu         = 1
  vm_disk_size   = 40
  vm_description = local.vms.mysql.description
  vm_tags        = concat(local.vms.mysql.tags, ["development"])
  ssh_public_key = tls_private_key.mysql_ssh.public_key_openssh
  user_password  = local.vms.mysql.password
  username       = local.vms.mysql.username
  
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
    module.dynamodb_vm,
    module.mysql_vm
  ]
  
  create_duration = "90s"  # Wait 90 seconds
}

# Generate Ansible Inventory
resource "local_file" "ansible_inventory" {
  depends_on = [time_sleep.wait_for_90s]

  filename = var.ansible_inventory_path

  content = templatefile("${path.module}/ansible/inventories/templates/inventory.tpl", {
    environment   = var.environment
    dynamodb_ip   = module.dynamodb_vm.ip_address
    mysql_ip      = module.mysql_vm.ip_address
    dynamodb_user = local.vms.dynamodb.username
    mysql_user    = local.vms.mysql.username
  })
}

# Run Ansible Playbooks
resource "null_resource" "ansible_provisioner" {
  depends_on = [
    local_file.ansible_inventory,
    local_file.dynamodb_private_key,
    local_file.mysql_private_key
  ]

  triggers = {
    dynamodb_ip = module.dynamodb_vm.ip_address
    mysql_ip    = module.mysql_vm.ip_address
    inventory   = md5(local_file.ansible_inventory.content)
  }

  # DynamoDB Provisioning
  provisioner "local-exec" {
    command = <<EOT
cd ${path.module}/ansible

echo "Provisioning DynamoDB on ${module.dynamodb_vm.ip_address}..."

ansible-playbook \
  -i inventories/inventory.ini \
  -u ${local.vms.dynamodb.username} \
  --private-key ${local.ssh_key_paths.dynamodb} \
  --limit dynamodb \
  playbooks/${var.setup_dynamodb_playbook}.yml
EOT

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_FORCE_COLOR       = "true"
    }
  }

  # MySQL Provisioning
  provisioner "local-exec" {
    command = <<EOT
cd ${path.module}/ansible

echo "Provisioning MySQL on ${module.mysql_vm.ip_address}..."

ansible-playbook \
  -i inventories/inventory.ini \
  -u ${local.vms.mysql.username} \
  --private-key ${local.ssh_key_paths.mysql} \
  --limit mysql \
  playbooks/${var.setup_mysql_playbook}.yml
EOT

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_FORCE_COLOR       = "true"
    }
  }
}