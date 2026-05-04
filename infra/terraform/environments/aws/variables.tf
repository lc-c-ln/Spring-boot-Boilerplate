variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "boilerplate"
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# RDS
variable "db_name"     { type = string; default = "boilerplate" }
variable "db_username" { type = string; default = "boilerplate" }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
}

# Application
variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}
variable "jwt_secret" {
  type      = string
  sensitive = true
}
variable "task_cpu"     { type = string; default = "512" }
variable "task_memory"  { type = string; default = "1024" }
variable "desired_count" { type = number; default = 1 }
variable "max_capacity"  { type = number; default = 4 }
