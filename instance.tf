resource "aws_security_group" "webserversg" {
  name   = "webserversg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "sg_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserversg.id
}

resource "aws_security_group_rule" "sg_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserversg.id
}

resource "aws_security_group_rule" "sg_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserversg.id
}

resource "aws_instance" "web_server" {
  ami               = "ami-0035ee596a0a12a7b"
  instance_type     = "t3.micro"
  availability_zone = "ap-southeast-2a"

  subnet_id = aws_subnet.first_subnet.id

  tags = {
    Name = "Web-server-1"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  associate_public_ip_address = true # public ip 할당

  vpc_security_group_ids = [aws_security_group.webserversg.id]
}