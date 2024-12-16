#!/bin/bash
# Update and install Apache
sudo yum update -y
sudo yum install -y httpd

# Start and enable the Apache service
sudo systemctl start httpd
sudo systemctl enable httpd

# Create a simple web page
echo "<html><body><h1>Hello from Terraform and Bash!</h1></body></html>" | sudo tee /var/www/html/index.html

#!/bin/bash
sudo apt update -y
sudo apt install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2

curl http://localhost
