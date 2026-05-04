locals {
  name = "${var.project_name}-${var.environment}"
}

resource "aws_db_subnet_group" "main" {
  name       = local.name
  subnet_ids = var.subnet_ids
  tags       = { Name = "${local.name}-db-subnet-group" }
}

resource "aws_security_group" "rds" {
  name   = "${local.name}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }
  tags = { Name = "${local.name}-rds-sg" }
}

resource "aws_db_instance" "main" {
  identifier = local.name

  engine         = "postgres"
  engine_version = "16.2"
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = var.backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  deletion_protection = var.deletion_protection
  skip_final_snapshot = !var.deletion_protection

  tags = { Name = "${local.name}-rds" }
}

# Secrets Manager에 DB 접속 정보 저장 (ECS task definition이 참조)
resource "aws_secretsmanager_secret" "db" {
  name                    = "${var.project_name}/${var.environment}/db"
  recovery_window_in_days = 7
  tags                    = { Environment = var.environment }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    host     = aws_db_instance.main.address
    port     = tostring(aws_db_instance.main.port)
    dbname   = aws_db_instance.main.db_name
    username = aws_db_instance.main.username
    password = var.db_password
  })
}
