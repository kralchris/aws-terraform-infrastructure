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

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-internship-kristijan"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-internet-gateway-internship-kristijan"
  }
}

# Public Subnet 1
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"
  tags = {
    Name = "public-subnet-1-internship-kristijan"
  }
}

# Public Subnet 2
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1b"
  tags = {
    Name = "public-subnet-2-internship-kristijan"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "public-route-table-internship-kristijan"
  }
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

# Private Subnet 1
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "private-subnet-1-internship-kristijan"
  }
}

# Private Subnet 2
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-1b"
  tags = {
    Name = "private-subnet-2-internship-kristijan"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = true
}

# NAT Gateway for Private Subnets
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "main-nat-gateway-internship-kristijan"
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "private-route-table-internship-kristijan"
  }
}

# Associate Private Subnets with Route Table
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

# EC2 Instance: T2 Micro with 20GB Encrypted EBS
resource "aws_instance" "t2_micro_instance" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public1.id

  root_block_device {
    volume_type   = "gp3"
    volume_size   = 20
    encrypted     = true
  }

  tags = {
    Name = "T2-Micro-Instance-internship-kristijan"
  }
}

# EC2 Instance: T2 Small with 20GB Encrypted EBS
resource "aws_instance" "t2_small_instance" {
  ami           = var.ami_id
  instance_type = "t2.small"
  subnet_id     = aws_subnet.public2.id

  root_block_device {
    volume_type   = "gp2"
    volume_size   = 20
    encrypted     = true
  }

  tags = {
    Name = "T2-Small-Instance-internship-kristijan"
  }
}
