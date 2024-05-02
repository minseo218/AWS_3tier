data "aws_subnet" "private1-subnet1" {
  filter {
    name   = "tag:Name"
    values = [var.private1-subnet-name1]
  }
}

data "aws_subnet" "private1-subnet2" {
  filter {
    name   = "tag:Name"
    values = [var.private1-subnet-name2]
  }
}

data "aws_subnet" "private2-subnet1" {
  filter {
    name   = "tag:Name"
    values = [var.private2-subnet-name1]
  }
}

data "aws_subnet" "private2-subnet2" {
  filter {
    name   = "tag:Name"
    values = [var.private2-subnet-name2]
  }
}


data "aws_security_group" "db-sg" {
  filter {
    name   = "tag:Name"
    values = [var.db-sg-name]
  }
}
