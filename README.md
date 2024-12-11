
# AWS Terraform Infrastructure Project

## Overview
This repository contains Terraform configurations and scripts to provision a cloud infrastructure setup, including VPC, EC2 instances, public subnets, security groups, and an application load balancer. The infrastructure is designed for scalability, reliability, and ease of use.

## Features
- **VPC Configuration**: Custom virtual private cloud setup to isolate and secure resources.
- **Public Subnets**: Defined public subnets for external-facing resources.
- **Security Groups**: Security rules to control inbound and outbound traffic.
- **EC2 Instances**: Virtual machines provisioned with a web server.
- **Application Load Balancer (ALB)**: High availability and traffic distribution across instances.
- **Automated Web Server Setup**: Bash script to configure Apache on EC2 instances.

## Diagram
![aws_diagram](https://github.com/user-attachments/assets/9b93bfa5-8422-404a-85d2-4be0783e8e34)


## File Structure
- `main.tf`: Entry point for Terraform configurations.
- `backend_setup.tf`: Configuration for remote state management.
- `backend.tf`: Additional backend-related configurations.
- `vpc.tf`: Definition of the VPC and related resources.
- `public_subnets.tf`: Configuration of public subnets.
- `security_groups.tf`: Definition of security groups.
- `ec2.tf`: EC2 instance provisioning and configuration.
- `alb.tf`: Setup of the application load balancer.
- `variables.tf`: Centralized variable definitions.
- `install_webserver.sh`: Bash script to install and configure a web server on EC2 instances.

## Prerequisites
- **Terraform**: Install Terraform version >= 1.0.0.
- **AWS CLI**: Install and configure AWS CLI with proper credentials.
- **IAM Role**: Ensure an IAM role with sufficient permissions for creating resources in AWS.
- **Key Pair**: AWS EC2 key pair for SSH access.

## Usage
1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```
2. **Initialize Terraform**:
   ```bash
   terraform init
   ```
3. **Plan the infrastructure**:
   ```bash
   terraform plan
   ```
4. **Apply the configuration**:
   ```bash
   terraform apply
   ```
   Confirm the execution by typing `yes` when prompted.
5. **Access the Web Server**:
   - Obtain the public IP address of the EC2 instance or ALB.
   - Open a browser and navigate to the public IP to see the default web page.

## Automated Web Server Setup
The script `install_webserver.sh` is used to:
- Install and start the Apache web server.
- Serve a simple HTML page with the message:
  ```html
  <html><body><h1>Hello from Terraform and Bash!</h1></body></html>
  ```

## Variables
Variables are defined in `variables.tf` for flexibility and reuse. Adjust these values as needed:
- **Region**: AWS region for resource provisioning.
- **Instance Type**: EC2 instance type.
- **Key Name**: Name of the AWS EC2 key pair.

## Outputs
- Public IP address of the EC2 instance.
- DNS name of the Application Load Balancer.

## Cleanup
To destroy all resources:
```bash
terraform destroy
```
Confirm the execution by typing `yes` when prompted.
