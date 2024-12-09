# KMS Key for S3 Bucket Encryption
resource "aws_kms_key" "terraform_state_key" {
  description             = "KMS key for encrypting Terraform state files"
  deletion_window_in_days = 30

  tags = {
    Name        = "terraform-state-encryption-key-internship-kristijan"
    Environment = "dev"
  }
}

resource "aws_kms_alias" "terraform_state_alias" {
  name          = "alias/terraform-state-key"
  target_key_id = aws_kms_key.terraform_state_key.id
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket-internship-kristijan"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.terraform_state_key.arn
      }
    }
  }

  tags = {
    Name        = "terraform-state-internship-kristijan"
    Environment = "dev"
  }
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-lock-table-internship-kristijan"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-lock-table-internship-kristijan"
    Environment = "dev"
  }
}
