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

#database instance#
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "aurora-serverless-cluster"
  engine                  = "aurora-mysql"
  engine_mode            = "serverless"
  master_username         = var.rds-username
  master_password         = var.rds-pwd
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