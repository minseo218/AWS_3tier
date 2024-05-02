data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"] 
}

data "aws_security_group" "web-sg" {
  filter {
    name   = "tag:Name"
    values = [var.web-sg-name]
  }
}

data "aws_security_group" "was-sg" {
  filter {
    name   = "tag:Name"
    values = [var.was-sg-name]
  }
}

data "aws_subnet" "public-subnet1" {
  filter {
    name   = "tag:Name"
    values = [var.public-subnet-name1]
  }
}

data "aws_subnet" "public-subnet2" {
  filter {
    name   = "tag:Name"
    values = [var.public-subnet-name2]
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

data "aws_lb_target_group" "web-tg" {
  tags = {
    Name = var.web-tg-name
  }
}

data "aws_lb_target_group" "was-tg" {
  tags = {
    Name = var.was-tg-name
  }
}

data "aws_iam_instance_profile" "instance-profile" {
  name = var.instance-profile-name
}