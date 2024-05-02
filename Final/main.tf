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
  #alias  = "sydeny"
  region = "ap-southeast-2"
}

provider "aws" { // waf는 버지니아에서만 가능 
  alias  = "Virginia"
  region = "us-east-1"
}

module "vpc" { // one public subnet, two private subnet 
  source = "./modules/aws-vpc"

  vpc-name       = var.VPC-NAME
  vpc-cidr       = var.VPC-CIDR
  igw-name       = var.IGW-NAME
  public-cidr1   = var.PUBLIC-CIDR1
  public-subnet1 = var.PUBLIC-SUBNET1
  public-cidr2   = var.PUBLIC-CIDR2
  public-subnet2 = var.PUBLIC-SUBNET2

  private1-cidr1   = var.PRIVATE1-CIDR1
  private1-subnet1 = var.PRIVATE1-SUBNET1
  private1-cidr2   = var.PRIVATE1-CIDR2
  private1-subnet2 = var.PRIVATE1-SUBNET2

  private2-cidr1   = var.PRIVATE2-CIDR1
  private2-subnet1 = var.PRIVATE2-SUBNET1
  private2-cidr2   = var.PRIVATE2-CIDR2
  private2-subnet2 = var.PRIVATE2-SUBNET2

  eip-name1 = var.EIP-NAME1
  eip-name2 = var.EIP-NAME2

  ngw-name1         = var.NGW-NAME1
  ngw-name2         = var.NGW-NAME2
  public-rt-name1   = var.PUBLIC-RT-NAME1
  public-rt-name2   = var.PUBLIC-RT-NAME2
  private1-rt-name1 = var.PRIVATE1-RT-NAME1
  private1-rt-name2 = var.PRIVATE1-RT-NAME2
  private2-rt-name1 = var.PRIVATE2-RT-NAME1
  private2-rt-name2 = var.PRIVATE2-RT-NAME2
}

module "security-group" {
  source = "./modules/security-group"

  vpc-name        = var.VPC-NAME
  web-alb-sg-name = var.WEB-ALB-SG-NAME
  web-sg-name     = var.WEB-SG-NAME
  was-alb-sg-name = var.WAS-ALB-SG-NAME
  was-sg-name     = var.WAS-SG-NAME
  db-sg-name      = var.DB-SG-NAME

  depends_on = [module.vpc]
}

module "aws-rds" {
  source                = "./modules/aws-rds"
  sg-name1              = var.SG-NAME1
  sg-name2              = var.SG-NAME2
  private1-subnet-name1 = var.PRIVATE1-SUBNET1
  private1-subnet-name2 = var.PRIVATE1-SUBNET2
  private2-subnet-name1 = var.PRIVATE2-SUBNET1
  private2-subnet-name2 = var.PRIVATE2-SUBNET2
  db-sg-name            = var.DB-SG-NAME
  rds-username          = var.RDS-USERNAME
  rds-pwd               = var.RDS-PWD
  db-name               = var.DB-NAME
  rds1-name             = var.RDS1-NAME
  rds2-name             = var.RDS2-NAME
  depends_on            = [module.security-group]
}

module "alb" {
  source                = "./modules/alb-tg"
  public-subnet-name1   = var.PUBLIC-SUBNET1
  public-subnet-name2   = var.PUBLIC-SUBNET2
  private1-subnet-name1 = var.PRIVATE1-SUBNET1
  private1-subnet-name2 = var.PRIVATE1-SUBNET2
  web-alb-sg-name       = var.WEB-ALB-SG-NAME
  was-alb-sg-name       = var.WAS-ALB-SG-NAME
  web-alb-name          = var.WEB-ALB-NAME
  was-alb-name          = var.WAS-ALB-NAME
  web-tg-name           = var.WEB-TG-NAME
  was-tg-name           = var.WAS-TG-NAME
  vpc-name              = var.VPC-NAME

  depends_on = [module.aws-rds]
}

module "iam" {
  source = "./modules/aws-iam"

  iam-role              = var.IAM-ROLE
  iam-policy            = var.IAM-POLICY
  instance-profile-name = var.INSTANCE-PROFILE-NAME

  depends_on = [module.alb]
}

module "autoscaling" {
  source                = "./modules/aws-autoscaling"
  ami_name              = var.AMI-NAME
  launch-template-name1 = var.LAUNCH-TEMPLATE-NAME1
  launch-template-name2 = var.LAUNCH-TEMPLATE-NAME2
  instance-profile-name = var.INSTANCE-PROFILE-NAME
  web-sg-name           = var.WEB-SG-NAME
  was-sg-name           = var.WAS-SG-NAME
  web-tg-name           = var.WEB-TG-NAME
  was-tg-name           = var.WAS-TG-NAME
  iam-role              = var.IAM-ROLE
  public-subnet-name1   = var.PUBLIC-SUBNET1
  public-subnet-name2   = var.PUBLIC-SUBNET2
  private1-subnet-name1 = var.PRIVATE1-SUBNET1
  private1-subnet-name2 = var.PRIVATE1-SUBNET2
  asg-name1             = var.ASG-NAME1
  asg-name2             = var.ASG-NAME2

  depends_on = [module.iam]
}

module "route53" {
  providers = {
    aws = aws.Virginia
    #default = aws.default
  }
  source       = "./modules/aws-waf-cdn-acm-route53"
  domain-name  = var.DOMAIN-NAME
  cdn-name     = var.CDN-NAME
  web_acl_name = var.WEB-ACL-NAME
  alb-dns-name = module.alb.alb_dns_name
}