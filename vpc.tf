##########################
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#########################

#------------------------------------------------------------------- VPC

resource "aws_vpc" "prod-vpc" {
  name = "${var.vpc-name}"
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

#------------------------------------------------------------------- Subnets

#- Public Subnet -#
resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-southeast-1a"

  tags = {
    Name  = "Public Subnet"
  }

}

#- Private Subnet -#
resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "Private Compute Subnet"
  }
}

#------------------------------------------------------------------- Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "${var.gw-name}"
  }
}

#------------------------------------------------------------------- Route Table

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

#- Associate subnet with route table -#
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.prod-route-table.id
}

#- NAt Gateway in Public Subnet : Allocate Elastic IP address -#
resource "aws_eip" "eip-for-nat-gateway" {
  vpc                       = true
  tags = {
    Name = "EIP 1"
  }
}

#- NAt Gateway in Public Subnet : Create NAt Gateway -#
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.eip-for-nat-gateway.id
  subnet_id     = aws_subnet.public-subnet.id
  tags = {
    Name = "NAT gateway"
  }
}

#- Private Route Table : Private Route Table and Add Route Through NAT gateway -#
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.prod-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }
  tags = {
    Name = "Private Route Table"
  }
}

# Associate Private Subnet with "Private Route Table"
resource "aws_route_table_association" "private-subnet-route-association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-route-table.id
}
