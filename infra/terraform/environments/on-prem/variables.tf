variable "project_name" {
  type    = string
  default = "boilerplate"
}

# 배포 대상 온프레미스 서버 IP 목록
variable "server_ips" {
  description = "List of on-premises server IP addresses"
  type        = list(string)
}

# SSH 접속 정보
variable "ssh_user" {
  type    = string
  default = "ubuntu"
}
variable "ssh_private_key_path" {
  description = "Path to SSH private key file"
  type        = string
}
variable "ssh_port" {
  type    = number
  default = 22
}

# ECR (AWS 환경에서 outputs으로 얻은 값을 입력)
variable "ecr_repository_url" {
  description = "ECR repository URL from AWS environment output"
  type        = string
}
variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}
variable "image_tag" {
  type    = string
  default = "latest"
}

# Application
variable "app_port" {
  type    = number
  default = 8080
}

# Database (온프레미스 로컬 Postgres)
variable "db_name"     { type = string; default = "boilerplate" }
variable "db_username" { type = string; default = "boilerplate" }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "jwt_secret" {
  type      = string
  sensitive = true
}
