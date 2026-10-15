terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "state-bucket" {
  bucket = "proj-terraform-eks-state-bucket"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_dynamodb_table" "state-dynamodb" {
  name             = "proj-terraform-eks-state-locks"
  hash_key         = "LockID"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}
