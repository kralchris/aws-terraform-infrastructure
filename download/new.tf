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
}

# Application Load Balancer (ALB)
resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-0123456789abcdef"]
  subnets            = ["subnet-abc123", "subnet-def456"]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "app_alb_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-xyz789"

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Network Load Balancer (NLB)
resource "aws_lb" "network_lb" {
  name               = "network-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["subnet-abc123", "subnet-def456"]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "network_lb_listener" {
  load_balancer_arn = aws_lb.network_lb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.network_tg.arn
  }
}

resource "aws_lb_target_group" "network_tg" {
  name     = "network-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = "vpc-xyz789"

  health_check {
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Security Groups
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = "vpc-xyz789"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nlb_sg" {
  name        = "nlb-sg"
  description = "Security group for NLB"
  vpc_id      = "vpc-xyz789"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
