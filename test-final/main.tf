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
  #alias = "default"
  region = "ap-southeast-2"
}

provider "aws" { //waf cloudfront는 버지니아에서만 가능 
  alias  = "Virginia"
  region = "us-east-1"
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