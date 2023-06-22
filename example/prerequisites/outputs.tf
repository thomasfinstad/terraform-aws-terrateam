output "endpoint" {
  description = "ALB Endpoint"
  value       = aws_route53_record.loadbalancer.fqdn
}

output "vpc" {
  description = "VPC Info"
  value = {
    subnets = {
      private = module.vpc.private_subnets
    }
  }
}

output "loadbalancer" {
  description = "Loadbalancer info"
  value = {
    target_group_arn = module.loadbalancer.target_group_arns[0]
    security_group   = aws_security_group.loadbalancer.id
  }
}

# aurora currently not suppored by terrateam
# output "rds" {
#   description = "RDS Info"
#   value = {
#     host           = module.rds.cluster_endpoint
#     port           = module.rds.cluster_port
#     name           = module.rds.cluster_database_name
#     master_user    = one(module.rds.cluster_master_user_secret)
#     security_group = module.rds.security_group_id
#   }
# }


output "rds" {
  description = "RDS Info"
  value = {
    host           = split(":", module.rds.db_instance_endpoint)[0]
    port           = module.rds.db_instance_port
    name           = module.rds.db_instance_name
    master_user    = one(data.aws_db_instance.this.master_user_secret) #one(module.rds.cluster_master_user_secret)
    security_group = aws_security_group.rds.id
  }
}
