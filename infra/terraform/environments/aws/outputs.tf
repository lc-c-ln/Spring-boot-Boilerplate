output "ecr_repository_url" {
  description = "ECR 이미지 주소 (CI/CD 파이프라인에서 사용)"
  value       = module.ecr.repository_url
}

output "alb_dns_name" {
  description = "ALB DNS 이름 (도메인 연결 시 CNAME으로 사용)"
  value       = module.ecs.alb_dns_name
}

output "rds_address" {
  description = "RDS 엔드포인트"
  value       = module.rds.db_address
}

output "ecs_cluster_name" { value = module.ecs.cluster_name }
output "ecs_service_name" { value = module.ecs.service_name }
