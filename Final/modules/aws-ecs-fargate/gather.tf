data "aws_subnet" "public-subnet1" {
  filter {
    name   = "tag:Name"
    values = [var.public-subnet-name1]
  }
}

data "aws_subnet" "public-subnet2" {
  filter {
    name   = "tag:Name"
    values = [var.private1-subnet-name2]
  }
}

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

data "aws_security_group" "web-alb-sg" {
  filter {
    name   = "tag:Name"
    values = [var.web-alb-sg-name]
  }
}

data "aws_security_group" "was-alb-sg" {
  filter {
    name   = "tag:Name"
    values = [var.was-alb-sg-name]
  }
}

data "aws_security_group" "was-sg" {
  filter {
    name   = "tag:Name"
    values = [var.was-sg-name]
  }
}
data "aws_security_group" "web-sg" {
  filter {
    name   = "tag:Name"
    values = [var.web-sg-name]
  }
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc-name]
  }
}

data "aws_alb_target_group" "web-tg" {
  name = var.web-tg-name
}

data "aws_alb_target_group" "was-tg" {
  name = var.was-tg-name
}