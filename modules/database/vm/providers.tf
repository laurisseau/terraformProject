terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.89.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
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

variable "environment" {
  type = string
  default = "development"
}

variable "project_name" {
  type = string
  default = "sportsify"
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

# Data Sources
data "aws_secretsmanager_secret" "aws_secretname" {
  name = "sportsify-dev-secrets"
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
