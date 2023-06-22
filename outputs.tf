output "security_group_id" {
  description = "ECS Service security group id. Usefull for adding non-default access rules"
  value       = aws_security_group.this.id
}
