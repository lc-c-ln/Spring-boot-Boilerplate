module "networking" {
  source = "../../modules/networking"

  project_name       = var.project_name
  environment        = "aws"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "ecr" {
  source       = "../../modules/ecr"
  project_name = var.project_name
  app_name     = "app"
}

module "rds" {
  source = "../../modules/rds"

  project_name = var.project_name
  environment  = "aws"
  vpc_id       = module.networking.vpc_id
  subnet_ids   = module.networking.private_subnet_ids

  allowed_security_group_ids = [module.ecs.app_security_group_id]

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  instance_class      = var.rds_instance_class
  deletion_protection = true
}

resource "aws_secretsmanager_secret" "jwt" {
  name                    = "${var.project_name}/aws/jwt-secret"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "jwt" {
  secret_id     = aws_secretsmanager_secret.jwt.id
  secret_string = var.jwt_secret
}

module "ecs" {
  source = "../../modules/ecs"

  project_name       = var.project_name
  environment        = "aws"
  aws_region         = var.aws_region
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  ecr_repository_url = module.ecr.repository_url
  image_tag          = var.image_tag

  db_secret_arn  = module.rds.secret_arn
  jwt_secret_arn = aws_secretsmanager_secret_version.jwt.arn
  secret_arns    = [module.rds.secret_arn, aws_secretsmanager_secret.jwt.arn]

  task_cpu      = var.task_cpu
  task_memory   = var.task_memory
  desired_count = var.desired_count
  max_capacity  = var.max_capacity
}
