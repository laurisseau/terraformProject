terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.89.1"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~>6.26.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# Data Sources
data "aws_secretsmanager_secret" "aws_secretname" {
  name = var.aws_secret_name
}

data "aws_secretsmanager_secret_version" "secrets" {
  secret_id = data.aws_secretsmanager_secret.aws_secretname.id
}

locals {
  awsSecrets = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)
}

provider "proxmox" {
  endpoint  = local.awsSecrets.PROXMOX_ENDPOINT
  api_token = local.awsSecrets.PROXMOX_API_TOKEN
  insecure  = true
}