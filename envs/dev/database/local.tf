locals {
  # AWS Secrets
  #awsSecrets = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)
  
  # VM Configuration
  vms = {
    dynamodb = {
      name        = var.dynamodb_vm_name
      description = "DynamoDB Server"
      tags        = ["dynamodb", "database", "nosql"]
      username    = "${var.dynamodb_vm_name}"
      password    = local.awsSecrets.DYNAMODB_PASSWORD
    }
    mysql = {
      name        = var.mysql_vm_name
      description = "MySQL Database Server"
      tags        = ["mysql", "database", "sql"]
      username    = "${var.mysql_vm_name}"
      password    = local.awsSecrets.MYSQL_PASSWORD
    }
  }
  
  # Common tags
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Created     = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  }
  
  # SSH key paths
  ssh_key_paths = {
    dynamodb = "${var.ssh_private_key_path}/${var.dynamodb_vm_name}.pem"
    mysql    = "${var.ssh_private_key_path}/${var.mysql_vm_name}.pem"
  }
}