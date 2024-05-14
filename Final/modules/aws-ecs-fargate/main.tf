## WEB
# ECS Task Execution IAM 역할 생성
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
  # IAM 역할에 ECR 읽기 권한을 인라인으로 부여
  inline_policy {
    name = "ECRReadPolicy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect   = "Allow",
        Action   = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        Resource = "arn:aws:ssm:*:*:parameter//rds/aurora-serverless-cluster/endpoint"
      },{
        Effect   = "Allow",
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "arn:aws:secretsmanager:*:*:secret:3tier/db/conn_info"
      },{
        Effect   = "Allow",
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource = "*"
      }]
    })
  }
}

# ECS Task Execution IAM 역할에 정책 연결
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Cluster
resource "aws_ecs_cluster" "web_cluster" {
  name = "web-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "web_task" {
  family                   = "web-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn  # ECS 태스크 실행 역할 연결
  container_definitions = jsonencode([
    {
      name      = "web-container"
      image     = "public.ecr.aws/t0o7z0m4/minseo-repo:web"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "web_service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.web_cluster.arn
  task_definition = aws_ecs_task_definition.web_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [data.aws_subnet.private1-subnet1.id, data.aws_subnet.private1-subnet2.id]
    security_groups = [data.aws_security_group.web-sg.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = data.aws_alb_target_group.web-tg.arn
    container_name   = "web-container"
    container_port   = 80
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "was_cluster" {
  name = "was-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "was_task" {
  family                   = "was-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn  # ECS 태스크 실행 역할 연결
  container_definitions = jsonencode([
    {
      name      = "was-container"
      image     = "public.ecr.aws/t0o7z0m4/minseo-repo:was"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "was_service" {
  name            = "was-service"
  cluster         = aws_ecs_cluster.was_cluster.arn
  task_definition = aws_ecs_task_definition.was_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [data.aws_subnet.private1-subnet1.id, data.aws_subnet.private1-subnet2.id]
    security_groups = [data.aws_security_group.was-sg.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = data.aws_alb_target_group.was-tg.arn
    container_name   = "was-container"
    container_port   = 8080
  }
}