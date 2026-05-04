output "deployed_servers" {
  description = "배포된 서버 IP 목록"
  value       = var.server_ips
}

output "app_url_examples" {
  description = "각 서버의 앱 접근 URL"
  value       = [for ip in var.server_ips : "http://${ip}"]
}
