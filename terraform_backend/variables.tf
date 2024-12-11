# variable "region" {
#   description = "AWS region for resources"
#   default     = "eu-west-1"
# }

# variable "instance_type" {
#   description = "EC2 instance type"
#   default     = "t2.micro"
# }

variable "ami_id" {
  description = "AMI ID for the EC2 instance -  Ubuntu"
  default     = "ami-0006134cba9099e65"
}