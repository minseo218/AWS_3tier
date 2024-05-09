# CodeBuild 서비스 역할 생성
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-AWS-3-tier-role-test"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# CodeBuild 서비스 역할에 필요한 권한 부여
resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name = "codebuild-policy-attachment"
  roles = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

# CodeBuild 프로젝트 생성
resource "aws_codebuild_project" "my_codebuild_project" {
  name          = var.build_project_name
  description   = "My CodeBuild project"
  service_role  = aws_iam_role.codebuild_role.arn
  source {
    type            = "GITHUB"
    location        = "https://github.com/minseo218/AWS-3-Tier-Service"
    buildspec       = "buildspec.yml"
  }
  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
  }
  artifacts {
    type            = "S3"
    location        = "test-artifacts-minseo"
    packaging       = "ZIP"
  }
}