module "db_firewall" {
  source = "../../../modules/security/security-groups"
  proxmox_node            = local.database_vms.mysql.proxmox_node
  security_group_name  = local.database_vms.firewall
  rules                = local.database_server_rules
  project_name         = var.project_name
  environment          = var.environment
  aws_region           = var.aws_region
  aws_secret_name      = var.aws_secret_name
}


module "apply_mysql_firewall" {
  source               = "../../../modules/security/apply-security-groups"
  proxmox_node            = local.database_vms.mysql.proxmox_node
  vm_id                = local.database_vms.mysql.vm_id
  security_group_name  = local.database_vms.firewall
  project_name         = var.project_name
  environment          = var.environment
  aws_region           = var.aws_region
  aws_secret_name      = var.aws_secret_name
}

module "apply_dynamodb_firewall" {
  source               = "../../../modules/security/apply-security-groups"
  proxmox_node            = local.database_vms.dynamodb.proxmox_node
  vm_id                = local.database_vms.dynamodb.vm_id
  security_group_name  = local.database_vms.firewall
  project_name         = var.project_name
  environment          = var.environment
  aws_region           = var.aws_region
  aws_secret_name      = var.aws_secret_name
}
