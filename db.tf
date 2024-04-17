#database instance#
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier     = "aurora-serverless-cluster"
  engine                 = "aurora-mysql"
  engine_mode            = "serverless"
  db_subnet_group_name   = aws_db_subnet_group.database-subnet-group.name
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  database_name          = var.db-name
  master_username        = var.db-username
  master_password        = var.db-password
  skip_final_snapshot    = true
}

#database subnets#

resource "aws_subnet" "db-subnet-1" {
  vpc_id            = aws_vpc.vpc_name.id
  cidr_block        = var.db-subnet1-cidr
  availability_zone = var.az_1

  tags = {
    Name = var.db-subnet1-name
  }
}

resource "aws_subnet" "db-subnet-2" {
  vpc_id            = aws_vpc.vpc_name.id
  cidr_block        = var.db-subnet2-cidr
  availability_zone = var.az_2

  tags = {
    Name = var.db-subnet2-name
  }
}

#database subnet group#

resource "aws_db_subnet_group" "database-subnet-group" {
  name       = var.db-subnet-grp-name
  subnet_ids = [aws_subnet.db-subnet-1.id, aws_subnet.db-subnet-2.id]

}
