locals {
  app_dir  = "/opt/${var.project_name}"
  ecr_image = "${var.ecr_repository_url}:${var.image_tag}"
  # ECR registry = repo URL에서 /project_name/app_name 앞부분
  ecr_registry = split("/", var.ecr_repository_url)[0]
}

# -------------------------------------------------------
# 서버별 배포 (SSH remote-exec)
# -------------------------------------------------------
resource "null_resource" "deploy" {
  for_each = toset(var.server_ips)

  # image_tag 변경 시 재실행
  triggers = {
    image_tag  = var.image_tag
    server_ip  = each.key
  }

  connection {
    type        = "ssh"
    host        = each.key
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    port        = var.ssh_port
    timeout     = "5m"
  }

  # 1) 앱 디렉터리 준비
  provisioner "remote-exec" {
    inline = ["sudo mkdir -p ${local.app_dir} && sudo chown ${var.ssh_user}:${var.ssh_user} ${local.app_dir}"]
  }

  # 2) .env 파일 업로드 (민감 정보)
  provisioner "file" {
    content = templatefile("${path.module}/templates/env.tpl", {
      db_name     = var.db_name
      db_username = var.db_username
      db_password = var.db_password
      jwt_secret  = var.jwt_secret
    })
    destination = "${local.app_dir}/.env"
  }

  # 3) docker-compose.yml 업로드
  provisioner "file" {
    content = templatefile("${path.module}/templates/docker-compose.yml.tpl", {
      ecr_image   = local.ecr_image
      app_name    = var.project_name
      app_port    = var.app_port
      db_name     = var.db_name
      db_username = var.db_username
      db_password = var.db_password
    })
    destination = "${local.app_dir}/docker-compose.yml"
  }

  # 4) nginx 설정 업로드
  provisioner "file" {
    content = templatefile("${path.module}/templates/nginx.conf.tpl", {
      app_port = var.app_port
    })
    destination = "${local.app_dir}/nginx.conf"
  }

  # 5) Docker 설치 (미설치 시), ECR 로그인, 배포
  provisioner "remote-exec" {
    inline = [
      # Docker 설치 여부 확인 후 설치
      "if ! command -v docker &>/dev/null; then",
      "  curl -fsSL https://get.docker.com | sudo sh",
      "  sudo usermod -aG docker ${var.ssh_user}",
      "  newgrp docker",
      "fi",

      # AWS CLI 설치 여부 확인 후 설치
      "if ! command -v aws &>/dev/null; then",
      "  sudo apt-get update -qq && sudo apt-get install -y -qq awscli",
      "fi",

      # ECR 로그인
      "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${local.ecr_registry}",

      # 이미지 Pull & 컨테이너 재시작
      "cd ${local.app_dir}",
      "docker compose pull app",
      "docker compose up -d --remove-orphans",

      # 미사용 이미지 정리
      "docker image prune -f",
    ]
  }
}
