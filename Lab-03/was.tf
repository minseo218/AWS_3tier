#app target group#

resource "aws_lb_target_group" "app-target-group" {
  name     = "tg-app-name"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_name.id
  health_check {
    path    = "/"
    matcher = 200
  }
}

resource "aws_lb_listener" "my_app_alb_listener" {
  load_balancer_arn = aws_lb.app-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-target-group.arn
  }
}


#app load balancer#

resource "aws_lb" "app-alb" {
  name               = var.alb-app-name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-app-sg.id]
  subnets            = [aws_subnet.app-subnet-1.id, aws_subnet.app-subnet-2.id]

}

#app auto scaling group#

resource "aws_autoscaling_group" "app-asg" {
  name                = var.asg-app-name
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.app-target-group.arn]
  health_check_type   = "EC2"
  vpc_zone_identifier = [aws_subnet.app-subnet-1.id, aws_subnet.app-subnet-2.id]

  launch_template {
    id      = aws_launch_template.app-launch-template.id
    version = "$Latest"
  }
}


#app auto scaling security group#

resource "aws_security_group" "app-asg-security-group" {
  name        = var.asg-sg-app-name
  description = "ASG Security Group"
  vpc_id      = aws_vpc.vpc_name.id

  ingress {
    description     = "HTTP from alb"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-app-sg.id]
  }

  ingress {
    description     = "SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-app-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.asg-sg-app-name
  }
}

#app launch template#

resource "aws_launch_template" "app-launch-template" {
  name          = var.launch-template-app-name
  image_id      = var.image-id
  instance_type = var.instance-type

  iam_instance_profile {
    name = aws_iam_instance_profile.session_manager_instance_profile.name # 인스턴스 프로파일 -> 세션 매니저 설정 
  }

  network_interfaces {
    device_index    = 0
    security_groups = [aws_security_group.web-asg-security-group.id]
  }

  tag_specifications {

    resource_type = "instance"
    tags = {
      Name = var.launch-template-app-name
    }
  }

}
