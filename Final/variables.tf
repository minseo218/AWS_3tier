# VPC
variable "VPC-NAME" {}
variable "VPC-CIDR" {}
variable "IGW-NAME" {}

variable "PUBLIC-CIDR1" {}
variable "PUBLIC-SUBNET1" {}
variable "PUBLIC-CIDR2" {}
variable "PUBLIC-SUBNET2" {}

variable "PRIVATE1-CIDR1" {}
variable "PRIVATE1-SUBNET1" {}
variable "PRIVATE1-CIDR2" {}
variable "PRIVATE1-SUBNET2" {}

variable "PRIVATE2-CIDR1" {}
variable "PRIVATE2-SUBNET1" {}
variable "PRIVATE2-CIDR2" {}
variable "PRIVATE2-SUBNET2" {}
variable "EIP-NAME1" {}
variable "EIP-NAME2" {}
variable "NGW-NAME1" {}
variable "NGW-NAME2" {}
variable "PUBLIC-RT-NAME1" {}
variable "PUBLIC-RT-NAME2" {}
variable "PRIVATE1-RT-NAME1" {}
variable "PRIVATE1-RT-NAME2" {}
variable "PRIVATE2-RT-NAME1" {}
variable "PRIVATE2-RT-NAME2" {}

# SECURITY GROUP
variable "WEB-ALB-SG-NAME" {}
variable "WAS-ALB-SG-NAME" {}
variable "WEB-SG-NAME" {}
variable "WAS-SG-NAME" {}
variable "DB-SG-NAME" {}

# RDS
variable "SG-NAME1" {}
variable "SG-NAME2" {}
variable "RDS-USERNAME" {}
variable "RDS-PWD" {}
variable "DB-NAME" {}
variable "RDS1-NAME" {}
variable "RDS2-NAME" {}


# ALB
variable "WEB-TG-NAME" {}
variable "WAS-TG-NAME" {}
variable "WEB-ALB-NAME" {}
variable "WAS-ALB-NAME" {}

# IAM
variable "IAM-ROLE" {}
variable "IAM-POLICY" {}
variable "INSTANCE-PROFILE-NAME" {}

# AUTOSCALING
variable "AMI-NAME" {}
variable "LAUNCH-TEMPLATE-NAME1" {}
variable "LAUNCH-TEMPLATE-NAME2" {}
variable "ASG-NAME1" {}
variable "ASG-NAME2" {}

# CLOUDFFRONT
variable "DOMAIN-NAME" {}
variable "CDN-NAME" {}

# WAF
variable "WEB-ACL-NAME" {}



# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}