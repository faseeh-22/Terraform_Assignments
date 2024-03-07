provider "aws" {
  region = "us-east-1" # Change to your desired region
}

# Create a VPC
resource "aws_vpc" "test_vpc" {
  cidr_block = "12.0.0.0/16" # Specify your desired CIDR block
  tags = {
    Name = "Test-VPC"
  }
}

# Create a public subnet
resource "aws_subnet" "test_public_subnet" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "12.0.1.0/24" # Specify your desired CIDR block for public subnet
  availability_zone = "us-east-1a" # Change to your desired availability zone
  map_public_ip_on_launch = true
  tags = {
    Name = "Test-PublicSubnet"
  }
}

# Create a private subnet
resource "aws_subnet" "test_private_subnet" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "12.0.2.0/24" # Specify your desired CIDR block for private subnet
  availability_zone = "us-east-1a" # Change to your desired availability zone
  tags = {
    Name = "Test-PrivateSubnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "Test-InternetGateway"
  }
}

# Create a route table for public subnet
resource "aws_route_table" "test_public_route_table" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "Test-PublicRouteTable"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }
}

# Associate public subnet with the public route table
resource "aws_route_table_association" "test_public_subnet_association" {
  subnet_id      = aws_subnet.test_public_subnet.id
  route_table_id = aws_route_table.test_public_route_table.id
}

# Create a NAT gateway
resource "aws_nat_gateway" "test_nat_gateway" {
  allocation_id = aws_eip.test_eip.id
  subnet_id     = aws_subnet.test_public_subnet.id
  tags = {
    Name = "TestNATGateway"
  }
}

# Create an Elastic IP for the NAT gateway
resource "aws_eip" "test_eip" {
  domain = "vpc"
  tags = {
    Name = "TestEIP"
  }
}

# Create a route table for private subnet
resource "aws_route_table" "test_private_route_table" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "Test-PrivateRouteTable"
  }
}

# Create a route for private subnet to route traffic through the NAT gateway
resource "aws_route" "test_private_subnet_route" {
  route_table_id         = aws_route_table.test_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.test_nat_gateway.id
}

# Associate private subnet with the private route table
resource "aws_route_table_association" "test_private_subnet_association" {
  subnet_id      = aws_subnet.test_private_subnet.id
  route_table_id = aws_route_table.test_private_route_table.id
}

