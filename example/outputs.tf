output "prerequsities" {
  description = "Prereq info"
  value       = module.prerequisites
}

output "terrateam" {
  description = "Terrateam info"
  value       = module.terrateam
}

output "endpoint" {
  description = "Terrateam ALB endpoint for github webhook url"
  value       = module.prerequisites.endpoint
}
