#!/bin/bash
# Update and install Apache
sudo yum update -y
sudo yum install -y httpd

# Start and enable the Apache service
sudo systemctl start httpd
sudo systemctl enable httpd

# Create a simple web page
echo "<html><body><h1>Hello from Terraform and Bash!</h1></body></html>" | sudo tee /var/www/html/index.html
