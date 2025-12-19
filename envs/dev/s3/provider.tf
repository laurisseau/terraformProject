terraform {
  backend "s3" {
    bucket = "dev-tf-state-bucket-ideeqrm7"
    key = "s3-infra/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
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

provider "random" {}