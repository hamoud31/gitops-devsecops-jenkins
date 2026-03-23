
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

# Generate a random suffix for uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "eks_bucket_remote_state" {
  bucket = "remote-tf-state-eks-infra-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "eks-bucket-remote-state"
  }
}

resource "aws_s3_bucket_versioning" "eks_bucket_versioning" {
  bucket = aws_s3_bucket.eks_bucket_remote_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "eks_bucket_encryption" {
  bucket = aws_s3_bucket.eks_bucket_remote_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "eks_bucket_public_access" {
  bucket = aws_s3_bucket.eks_bucket_remote_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
