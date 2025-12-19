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


resource "aws_s3_object" "folder_structure" {
  for_each = toset([
    "db-infra/",           # Will create empty folder object
    "s3-infra/",           # Will create empty folder object  
    "compute-infra/",
    "vpc-infra/",
    "sg-infra/"
  ])
  
  bucket = aws_s3_bucket.dev-tf-state-bucket.bucket
  key    = each.value
  content = ""
}

# MAKE S3 MODULE TO CREATE A BUCKET WITH FOLDERS