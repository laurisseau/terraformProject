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
  region = "us-east-1"
}

# Data source to retrieve the secret
data "aws_secretsmanager_secret" "aws_secretname" {
  name = "sportsify-dev-secrets"
}

data "aws_secretsmanager_secret_version" "secrets" {
  secret_id = data.aws_secretsmanager_secret.aws_secretname.id
}

locals {
  awsSecrets = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)
}

provider "random" {}

# Create a random string
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "dev-tf-state-bucket" {
  bucket = "dev-tf-state-bucket-${random_string.suffix.result}"

  tags = {
    Name        = "Terraform state bucket"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "dev-tf-state-bucket" {
  bucket = aws_s3_bucket.dev-tf-state-bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "dev-tf-state-bucket" {
  bucket = aws_s3_bucket.dev-tf-state-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "dev-tf-state-bucket" {
  bucket = aws_s3_bucket.dev-tf-state-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "tf-state-s3"{
    value = aws_s3_bucket.dev-tf-state-bucket.bucket
}

