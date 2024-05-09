# set provider
terraform {
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  #alias  = "singapore"
  region = "ap-southeast-1"
}

module "s3" {
  source = "./modules/s3/"
}

module "code-build" {
  source     = "./modules/code-build/"
  build_project_name   = var.build_project_name
  depends_on = [module.s3]
}

module "code-deploy" {
  source     = "./modules/code-deploy/"
  deploy_application_name = var.deploy_application_name
  deploy_group_name = var.deploy_group_name
  depends_on = [module.code-build]
}

module "code-pipeline" {
  source     = "./modules/code-pipeline/"
  build_project_name   = var.build_project_name
  deploy_application_name = var.deploy_application_name
  deploy_group_name = var.deploy_group_name
  github_token_parameter_name = var.github_token_parameter_name
  depends_on = [module.code-deploy]
}