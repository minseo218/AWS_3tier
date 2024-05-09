# S3 버킷 액세스 권한 정책 생성
resource "aws_iam_policy" "codepipeline_s3_access" {
  name        = "CodePipelineS3AccessPolicy"
  description = "Allows CodePipeline to access S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          "arn:aws:s3:::<your-s3-bucket-name>",
          "arn:aws:s3:::<your-s3-bucket-name>/*"
        ]
      }
    ]
  })
}

# CodePipeline 서비스 역할 생성
resource "aws_iam_role" "role_codepipeline" {
  name = "AWSCodePipelineServiceRole-ap-southeast-1-3-tier"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

# 정책을 CodePipeline 역할에 연결
resource "aws_iam_role_policy_attachment" "codepipeline_s3_access_attachment" {
  role       = aws_iam_role.role_codepipeline.name
  policy_arn = aws_iam_policy.codepipeline_s3_access.arn
}

# CodePipeline 서비스 역할에 필요한 권한 부여
resource "aws_iam_policy_attachment" "codepipeline_policy_attachment" {
  name = "codepipeline-policy-attachment"
  roles = [aws_iam_role.role_codepipeline.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineCustomActionAccess" # 적절한 정책 ARN으로 변경
}

# github 토큰 가져오기 (Secret manager 생성은 콘솔에서 진행)
data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "3tier/cicd/git/token"
}

# CodePipeline 파이프라인 생성
resource "aws_codepipeline" "tier3_was_pipeline" {
  name     = "3-tier-was"
  role_arn = aws_iam_role.role_codepipeline.arn
  artifact_store {
    location = "test-artifacts-minseo" # CodeBuild 프로젝트에서 생성되는 아티팩트가 저장되는 S3 버킷 이름으로 변경
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        Owner               = "minseo218"
        Repo                = "AWS-3-Tier-Service"
        Branch              = "main"
        # git version 1이라서 곧 사용 종료 될 수 도 있음
        OAuthToken          = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["OAuth token"]
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name            = "BuildAction"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      configuration = {
        ProjectName = var.build_project_name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "DeployAction"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      configuration = {
        ApplicationName = var.deploy_application_name
        DeploymentGroupName = var.deploy_group_name
      }
    }
  }
}
