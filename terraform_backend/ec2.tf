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
  vpc = true
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
resource "aws_instance" "webserver_1" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private1.id

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name = "webserver-1-internship-kristijan"
  }
}

# EC2 Instance: T2 Micro with 20GB Encrypted EBS
resource "aws_instance" "webserver_2" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private2.id

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name = "webserver-2-internship-kristijan"
  }
}
