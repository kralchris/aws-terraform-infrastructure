# AWS Provider Configuration
provider "aws" {
  region = "eu-west-1"
}

# Terraform Backend Configuration
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-internship-kristijan"
    key            = "terraform/state/default.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock-table-internship-kristijan"
    encrypt        = true
  }
}
