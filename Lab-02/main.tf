# vpc
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "tf-vpc"
  }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main_igw"
  }
}

# public subnet
resource "aws_subnet" "first_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.10.0/24"

  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "second_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.40.0/24"

  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "pubilc-subnet-2"
  }
}

# private subnet
resource "aws_subnet" "first_private_subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.20.0/24"

  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "private-subnet-1a"
  }
}

resource "aws_subnet" "first_private_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.30.0/24"

  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "private-subnet-2a"
  }
}

resource "aws_subnet" "secound_private_subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.50.0/24"

  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "private-subnet-1b"
  }
}

resource "aws_subnet" "secound_private_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.60.0/24"

  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "private-subnet-2b"
  }
}

# Elastic ip abbress
resource "aws_eip" "nat_1" {
  domain = "vpc"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "nat_2" {
  domain = "vpc"

  lifecycle {
    create_before_destroy = true
  }
}

# Nat gateway
resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.first_subnet.id
  tags = {
    Name = "NAT-GW-1"
  }
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.second_subnet.id
  tags = {
    Name = "NAT-GW-2"
  }
}

# Pubilc route table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "route_table_association_1" {
  subnet_id      = aws_subnet.first_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "route_table_association_2" {
  subnet_id      = aws_subnet.second_subnet.id
  route_table_id = aws_route_table.route_table.id
}

# Private route table
resource "aws_route_table" "route_table_private_1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt-a"
  }
}

resource "aws_route_table" "route_table_private_2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt-b"
  }
}

resource "aws_route" "private_nat_1" {
  route_table_id         = aws_route_table.route_table_private_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_1.id
}

resource "aws_route" "private_nat_2" {
  route_table_id         = aws_route_table.route_table_private_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_2.id
}

resource "aws_route_table_association" "route_table_association_private_1a" {
  subnet_id      = aws_subnet.first_private_subnet_1.id
  route_table_id = aws_route_table.route_table_private_1.id
}

resource "aws_route_table_association" "route_table_association_private_2a" {
  subnet_id      = aws_subnet.first_private_subnet_2.id
  route_table_id = aws_route_table.route_table_private_1.id
}

resource "aws_route_table_association" "route_table_association_private_1b" {
  subnet_id      = aws_subnet.secound_private_subnet_1.id
  route_table_id = aws_route_table.route_table_private_2.id
}

resource "aws_route_table_association" "route_table_association_private_2b" {
  subnet_id      = aws_subnet.secound_private_subnet_2.id
  route_table_id = aws_route_table.route_table_private_2.id
}
