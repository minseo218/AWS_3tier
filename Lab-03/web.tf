#web load balancer#

resource "aws_lb" "web-alb" {
  name               = var.alb-web-name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-web-sg.id]
  subnets            = [aws_subnet.app-subnet-1.id, aws_subnet.app-subnet-2.id] # 변경한 부분 
}

#web auto scaling group#

resource "aws_autoscaling_group" "web-asg" {
  name                = var.asg-web-name
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.web-target-group.arn]
  health_check_type   = "EC2"
  vpc_zone_identifier = [aws_subnet.app-subnet-1.id, aws_subnet.app-subnet-2.id] # 변경한 부분 

  launch_template {
    id      = aws_launch_template.web-launch-template.id
    version = "$Latest"
  }
}

#web auto scaling security group#

resource "aws_security_group" "web-asg-security-group" {
  name        = var.asg-sg-web-name
  description = "ASG Security Group"
  vpc_id      = aws_vpc.vpc_name.id
  ingress {
    description     = "HTTP from alb"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-web-sg.id]
  }

  ingress {
    description     = "SSH from anywhere"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-web-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.asg-sg-web-name
  }
}

data "aws_iam_role" "session_manager_role" {
  name = "sessionManagerRole"
}

resource "aws_iam_instance_profile" "session_manager_instance_profile" {
  name = "session-manager-instance-profile"
  role = data.aws_iam_role.session_manager_role.name
}

#web launch template#
resource "aws_launch_template" "web-launch-template" {
  name          = var.launch-template-web-name
  image_id      = var.image-id
  instance_type = var.instance-type
  user_data     = filebase64("${path.module}/userdata.sh")

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
      Name = var.launch-template-web-name
    }
  }
}

#web target group#

resource "aws_lb_target_group" "web-target-group" {
  name     = "tg-web-name"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_name.id
  health_check {
    path    = "/"
    matcher = 200
  }

}

resource "aws_lb_listener" "my_web_alb_listener" {
  load_balancer_arn = aws_lb.web-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-target-group.arn
  }
}
