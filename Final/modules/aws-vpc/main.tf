# Creating VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc-cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true


  tags = {
    Name = var.vpc-name
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw-name
  }
  depends_on = [ aws_vpc.vpc ]
}

# az setting 
data "aws_availability_zones" "available" {
  state = "available"
}

# Creating Public Subnet 1 for NAT
resource "aws_subnet" "public-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public-cidr1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = var.public-subnet1
  }

  depends_on = [ aws_internet_gateway.igw ]
}

# Creating Public Subnet 2 for NAT
resource "aws_subnet" "public-subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public-cidr2
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = var.public-subnet2
  }

  depends_on = [ aws_subnet.public-subnet1 ]
}

# Creating Private1 Subnet 1 for WEB, WAS
resource "aws_subnet" "private1-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private1-cidr1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = var.private1-subnet1
  }

  depends_on = [ aws_subnet.public-subnet2 ]
}

# Creating Private1 Subnet 2 for WEB, WAS
resource "aws_subnet" "private1-subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private1-cidr2
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = var.private1-subnet2
  }

  depends_on = [ aws_subnet.private1-subnet1 ]
}

# Creating Private2 Subnet 1 for DB
resource "aws_subnet" "private2-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private2-cidr1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = var.private2-subnet1
  }

  depends_on = [ aws_subnet.public-subnet2 ]
}

# Creating Private2 Subnet 2 for DB
resource "aws_subnet" "private2-subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private2-cidr2
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = var.private2-subnet2
  }

  depends_on = [ aws_subnet.private2-subnet1 ]
}


# Creating Elastic IP for NAT Gateway 1
resource "aws_eip" "eip1" {
  domain = "vpc"

  tags = {
    Name = var.eip-name1
  }

  depends_on = [ aws_subnet.private2-subnet2 ]
}

# Creating Elastic IP for NAT Gateway 2
resource "aws_eip" "eip2" {
  domain = "vpc"

  tags = {
    Name = var.eip-name2
  }

  depends_on = [ aws_eip.eip1 ]
}

# Creating NAT Gateway 1
resource "aws_nat_gateway" "ngw1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public-subnet1.id

  tags = {
    Name = var.ngw-name1
  }

  depends_on = [ aws_eip.eip2 ]
}

# Creating NAT Gateway 2
resource "aws_nat_gateway" "ngw2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public-subnet2.id

  tags = {
    Name = var.ngw-name2
  }

  depends_on = [ aws_nat_gateway.ngw1 ]
}

# Creating Public Route table 1
resource "aws_route_table" "public-rt1" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public-rt-name1
  }

  depends_on = [ aws_nat_gateway.ngw2 ]
}

# Associating the Public Route table 1 Public Subnet 1
resource "aws_route_table_association" "public-rt-association1" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.public-rt1.id

  depends_on = [ aws_route_table.public-rt1 ]
}

# Creating Public Route table 2 
resource "aws_route_table" "public-rt2" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public-rt-name2
  }
  
  depends_on = [ aws_route_table_association.public-rt-association1 ]
}

# Associating the Public Route table 2 Public Subnet 2
resource "aws_route_table_association" "public-rt-association2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.public-rt2.id

  depends_on = [ aws_route_table.public-rt1 ]
}


# Creating Private1 Route table 1
resource "aws_route_table" "private1-rt1" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw1.id
  }

  tags = {
    Name = var.private1-rt-name1
  }

  depends_on = [ aws_route_table_association.public-rt-association2 ]
}

# Associating the Private1 Route table 1 Private Subnet 1
resource "aws_route_table_association" "private1-rt-association1" {
  subnet_id      = aws_subnet.private1-subnet1.id
  route_table_id = aws_route_table.private1-rt1.id

  depends_on = [ aws_route_table.private1-rt1 ]
}

# Creating Private1 Route table 2 
resource "aws_route_table" "private1-rt2" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw2.id
  }

  tags = {
    Name = var.private1-rt-name2
  }

  depends_on = [ aws_route_table_association.private1-rt-association1 ]
}

# Associating the Private1 Route table 2 Private Subnet 2
resource "aws_route_table_association" "private1-rt-association2" {
  subnet_id      = aws_subnet.private1-subnet2.id
  route_table_id = aws_route_table.private1-rt2.id

  depends_on = [ aws_route_table.private1-rt2 ]
}

# Creating Private2 Route table 1
resource "aws_route_table" "private2-rt1" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw1.id
  }

  tags = {
    Name = var.private2-rt-name1
  }

  depends_on = [ aws_route_table_association.public-rt-association2 ]
}

# Associating the Private2 Route table 1 Private2 Subnet 1
resource "aws_route_table_association" "private2-rt-association1" {
  subnet_id      = aws_subnet.private2-subnet1.id
  route_table_id = aws_route_table.private2-rt1.id

  depends_on = [ aws_route_table.private2-rt1 ]
}

# Creating Private2 Route table 2 
resource "aws_route_table" "private2-rt2" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw2.id
  }

  tags = {
    Name = var.private2-rt-name2
  }

  depends_on = [ aws_route_table_association.private2-rt-association1 ]
}

# Associating the Private2 Route table 2 Private2 Subnet 2
resource "aws_route_table_association" "private2-rt-association2" {
  subnet_id      = aws_subnet.private2-subnet2.id
  route_table_id = aws_route_table.private2-rt2.id

  depends_on = [ aws_route_table.private2-rt2 ]
}