variable "project_name"       { type = string }
variable "environment"        { type = string }
variable "aws_region"         { type = string }
variable "vpc_id"             { type = string }
variable "public_subnet_ids"  { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "ecr_repository_url" { type = string }
variable "image_tag"          { type = string; default = "latest" }
variable "app_port"           { type = number; default = 8080 }
variable "db_secret_arn"      { type = string }
variable "jwt_secret_arn"     { type = string }
variable "secret_arns"        { type = list(string) }

variable "task_cpu"     { type = string; default = "512" }
variable "task_memory"  { type = string; default = "1024" }

variable "desired_count" { type = number; default = 1 }
variable "max_capacity"  { type = number; default = 4 }
