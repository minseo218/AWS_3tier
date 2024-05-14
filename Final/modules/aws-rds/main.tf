# 8 Creating DB subnet group for RDS Instances_1
resource "aws_db_subnet_group" "db_subnet_group1" {
  name       = var.sg-name1
  subnet_ids = [data.aws_subnet.private1-subnet1.id, data.aws_subnet.private1-subnet2.id]
}

# 8 Creating DB subnet group for RDS Instances_2
resource "aws_db_subnet_group" "db_subnet_group2" {
  name       = var.sg-name2
  subnet_ids = [data.aws_subnet.private2-subnet1.id, data.aws_subnet.private2-subnet2.id]
}

# az setting 
data "aws_availability_zones" "available" {
  state = "available"
}
# RDS secret ( AWS Secrets Manager에서 시크릿 가져오기 )
data "aws_secretsmanager_secret_version" "db_conn_info" {
  secret_id = "3tier/db/conn_info"
}


#database instance#
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "aurora-serverless-cluster"
  engine                  = "aurora-mysql"
  engine_mode            = "serverless"
  # secret 변수 할당
  master_username         = jsondecode(data.aws_secretsmanager_secret_version.db_conn_info.secret_string)["username"]
  master_password         = jsondecode(data.aws_secretsmanager_secret_version.db_conn_info.secret_string)["password"]
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  database_name           = var.db-name
  port                    = 3306
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group1.name
  # set specificate availability zone 
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  vpc_security_group_ids  = [data.aws_security_group.db-sg.id]
  tags = {
    Name = var.rds1-name
  }
}

# RDS 데이터베이스 엔드포인트 주소를 Parameter Store에 저장
resource "aws_ssm_parameter" "rds_endpoint" {
  name  = "/rds/aurora-serverless-cluster/endpoint"
  type  = "String"
  value = aws_rds_cluster.aurora_cluster.endpoint
}
