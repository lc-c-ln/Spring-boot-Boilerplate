output "db_address"   { value = aws_db_instance.main.address }
output "db_port"      { value = aws_db_instance.main.port }
output "db_name"      { value = aws_db_instance.main.db_name }
output "secret_arn"   { value = aws_secretsmanager_secret.db.arn }
output "secret_name"  { value = aws_secretsmanager_secret.db.name }
