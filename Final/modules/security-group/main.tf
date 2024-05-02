resource "aws_security_group" "web-alb-sg" {
  vpc_id      = data.aws_vpc.vpc.id
  description = "Allow HTTP and HTTPS for World"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.web-alb-sg-name
  }
}

resource "aws_security_group" "web-tier-sg" {
  vpc_id      = data.aws_vpc.vpc.id
  description = "Allow HTTP and HTTPS for ALB Only"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-alb-sg.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.web-alb-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.web-sg-name
  }
}

resource "aws_security_group" "was-alb-sg" {
  vpc_id      = data.aws_vpc.vpc.id
  description = "Allow WEB EC2 ONLY"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.web-tier-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.was-alb-sg-name
  }
}

resource "aws_security_group" "was-tier-sg" {
  vpc_id      = data.aws_vpc.vpc.id
  description = "Allow HTTP and HTTPS for WEB Only"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.was-alb-sg.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.was-sg-name
  }
}

# Creating Security Group for RDS Instances Tier With  only access to App-Tier ALB
resource "aws_security_group" "database-sg" {
  vpc_id      = data.aws_vpc.vpc.id
  description = "Protocol Type MySQL/Aurora"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.was-tier-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.db-sg-name
  }
}