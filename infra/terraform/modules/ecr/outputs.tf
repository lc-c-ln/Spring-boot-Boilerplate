output "repository_url" {
  description = "Full ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "registry_id" {
  description = "ECR registry ID (AWS account ID)"
  value       = aws_ecr_repository.app.registry_id
}

output "repository_name" {
  value = aws_ecr_repository.app.name
}
