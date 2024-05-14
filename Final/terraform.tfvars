# VPC
VPC-NAME          = "3-Tier-VPC"
VPC-CIDR          = "192.168.0.0/16"
IGW-NAME          = "3-Tier-Interet-Gateway"
PUBLIC-CIDR1      = "192.168.10.0/24"
PUBLIC-SUBNET1    = "3-Tier-Public-Subnet1"
PUBLIC-CIDR2      = "192.168.40.0/24"
PUBLIC-SUBNET2    = "3-Tier-Public-Subnet2"
PRIVATE1-CIDR1    = "192.168.20.0/24"
PRIVATE1-SUBNET1  = "3-Tier-Private1-Subnet1"
PRIVATE1-CIDR2    = "192.168.50.0/24"
PRIVATE1-SUBNET2  = "3-Tier-Private1-Subnet2"
PRIVATE2-CIDR1    = "192.168.30.0/24"
PRIVATE2-SUBNET1  = "3-Tier-Private2-Subnet1"
PRIVATE2-CIDR2    = "192.168.60.0/24"
PRIVATE2-SUBNET2  = "3-Tier-Private2-Subnet2"
EIP-NAME1         = "3-Tier-Elastic-IP1"
EIP-NAME2         = "3-Tier-Elastic-IP2"
NGW-NAME1         = "3-Tier-NAT1"
NGW-NAME2         = "3-Tier-NAT2"
PUBLIC-RT-NAME1   = "3-Tier-Public-Route-table1"
PUBLIC-RT-NAME2   = "3-Tier-Public-Route-table2"
PRIVATE1-RT-NAME1 = "3-Tier-Private1-Route-table1"
PRIVATE1-RT-NAME2 = "3-Tier-Private1-Route-table2"
PRIVATE2-RT-NAME1 = "3-Tier-Private2-Route-table1"
PRIVATE2-RT-NAME2 = "3-Tier-Private2-Route-table2"

# SECURITY GROUP
WEB-ALB-SG-NAME = "3-Tier-web-alb-sg"
WAS-ALB-SG-NAME = "3-Tier-was-alb-sg"
WEB-SG-NAME     = "3-Tier-web-sg"
WAS-SG-NAME     = "3-Tier-was-sg"
DB-SG-NAME      = "3-Tier-db-sg"

# RDS
SG-NAME1 = "sg-3-tier-rds1" #subnetgroup
SG-NAME2 = "sg-3-tier-rds2"
#RDS-USERNAME = "admin"
#RDS-PWD      = "Admin1234"
DB-NAME   = "demo"
RDS1-NAME = "3-Tier-RDS1"
RDS2-NAME = "3-Tier-RDS2"




# ALB
WEB-TG-NAME  = "Web-TG"
WAS-TG-NAME  = "Was-TG"
WEB-ALB-NAME = "Web-elb"
WAS-ALB-NAME = "Was-elb"

# IAM
IAM-ROLE              = "iam-role-for-ec2-SSM-s3-cw-cd-kms"
IAM-POLICY            = "iam-policy-for-ec2-SSM-s3-cw-cd-kms"
INSTANCE-PROFILE-NAME = "iam-instance-profile-for-ec2-SSM-s3-cw-cd-kms"



# AUTOSCALING
AMI-NAME              = "New-AMI"
LAUNCH-TEMPLATE-NAME1 = "Web-template"
LAUNCH-TEMPLATE-NAME2 = "Was-template"
ASG-NAME1             = "3-Tier-ASG-web"
ASG-NAME2             = "3-Tier-ASG-was"


# CLOUDFRONT
DOMAIN-NAME = "minsunny.store"
CDN-NAME    = "3-Tier-CDN-kms"

# WAF
WEB-ACL-NAME = "3-Tier-WAF-kms"