# CodeDeploy 서비스 역할 생성
resource "aws_iam_role" "role_deploy_3tier" {
  name = "role-deploy-3tier"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

# CodeDeploy 서비스 역할에 필요한 권한 부여
resource "aws_iam_policy_attachment" "codedeploy_policy_attachment" {
  name = "codedeploy-policy-attachment"
  roles = [aws_iam_role.role_deploy_3tier.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole" # 적절한 정책 ARN으로 변경
}

# CodeDeploy 애플리케이션 생성
resource "aws_codedeploy_app" "deploy_3tier" {
  name = var.deploy_application_name
}

# CodeDeploy 배포 그룹 생성
resource "aws_codedeploy_deployment_group" "deploy_group_3tier" {
  app_name = aws_codedeploy_app.deploy_3tier.name
  deployment_group_name = var.deploy_group_name
  service_role_arn = aws_iam_role.role_deploy_3tier.arn
  autoscaling_groups = ["3-Tier-ASG-was"] # Auto Scaling 그룹 이름으로 변경
  deployment_config_name = "CodeDeployDefault.OneAtATime" # 기본 배포 설정 사용
  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }
  }
}

