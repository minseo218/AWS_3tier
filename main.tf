terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}


#vpc creation#

resource "aws_vpc" "vpc_name" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.vpc-name
  }
}

#create IGW#

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_name.id
  tags = {
    Name = var.igw-name
  }
}

###elastic IP address###

resource "aws_eip" "eip-address" {
  domain = "vpc"
}

#create NGW#

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.eip-address.id
  subnet_id     = aws_subnet.app-subnet-1.id

  tags = {
    Name = var.nat-gw-name
  }

  depends_on = [aws_internet_gateway.igw]
}

#web subnets#

resource "aws_subnet" "web-subnet-1" {
  vpc_id                  = aws_vpc.vpc_name.id
  cidr_block              = var.web-subnet1-cidr
  availability_zone       = var.az_1
  map_public_ip_on_launch = true

  tags = {
    Name = var.web-subnet1-name
  }
}

resource "aws_subnet" "web-subnet-2" {
  vpc_id                  = aws_vpc.vpc_name.id
  cidr_block              = var.web-subnet2-cidr
  availability_zone       = var.az_2
  map_public_ip_on_launch = true

  tags = {
    Name = var.web-subnet2-name
  }
}

#app subnets#

resource "aws_subnet" "app-subnet-1" {
  vpc_id            = aws_vpc.vpc_name.id
  cidr_block        = var.app-subnet1-cidr
  availability_zone = var.az_1

  tags = {
    Name = var.app-subnet1-name
  }
}

resource "aws_subnet" "app-subnet-2" {
  vpc_id            = aws_vpc.vpc_name.id
  cidr_block        = var.app-subnet2-cidr
  availability_zone = var.az_2

  tags = {
    Name = var.app-subnet2-name
  }
}

#public route table#

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc_name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt-name"
  }
}
resource "aws_route_table_association" "public-rt-association1" {
  subnet_id      = aws_subnet.web-subnet-1.id
  route_table_id = aws_route_table.public-rt.id
}


resource "aws_route_table_association" "public-rt-association2" {
  subnet_id      = aws_subnet.web-subnet-2.id
  route_table_id = aws_route_table.public-rt.id
}

#private route table#

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc_name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = "private-rt-name"
  }
}

resource "aws_route_table_association" "private-rt-association1" {
  subnet_id      = aws_subnet.app-subnet-1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-rt-association2" {
  subnet_id      = aws_subnet.app-subnet-2.id
  route_table_id = aws_route_table.private-rt.id
}