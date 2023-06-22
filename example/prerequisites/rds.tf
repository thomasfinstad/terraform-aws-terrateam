# data "aws_rds_engine_version" "postgresql" {
#   engine      = "aurora-postgresql"
#   version     = "15"
#   include_all = false

#   filter {
#     name   = "engine-mode"
#     values = ["provisioned"]
#   }
# }

resource "aws_db_subnet_group" "this" {
  name       = "private-subnets"
  subnet_ids = module.vpc.private_subnets
}

# aurora currently not supported by terrateam (md5 password hashing only)
# module "rds" {
#   source  = "terraform-aws-modules/rds-aurora/aws"
#   version = "8.3.1"

#   name          = var.name
#   database_name = "terrateam"

#   engine         = data.aws_rds_engine_version.postgresql.engine
#   engine_mode    = "provisioned"
#   engine_version = data.aws_rds_engine_version.postgresql.version

#   storage_encrypted           = true
#   master_username             = "terrateam"
#   manage_master_user_password = true

#   vpc_id               = module.vpc.vpc_id
#   db_subnet_group_name = aws_db_subnet_group.this.name

#   monitoring_interval = 60

#   apply_immediately   = true
#   skip_final_snapshot = true

#   serverlessv2_scaling_configuration = {
#     min_capacity = 0.5
#     max_capacity = 3
#   }

#   instances      = { "1" = {} }
#   instance_class = "db.serverless"
# }



#####
# Non-aurora db
resource "aws_security_group" "rds" {
  name   = "${var.name}-rds"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "rds_self_ingress" {
  from_port         = 0
  protocol          = "tcp"
  security_group_id = aws_security_group.rds.id
  to_port           = 0
  type              = "ingress"
  self              = true
  description       = "Assist in debugging"
}

resource "aws_security_group_rule" "rds_self_egress" {
  from_port         = 0
  protocol          = "tcp"
  security_group_id = aws_security_group.rds.id
  to_port           = 0
  type              = "egress"
  self              = true
  description       = "Assist in debugging"
}

data "aws_db_instance" "this" {
  depends_on             = [module.rds]
  db_instance_identifier = module.rds.db_instance_identifier
}

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.name

  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name                     = "terrateam"
  username                    = "terratsrv"
  manage_master_user_password = true

  #iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "${var.name}-RDSMonitoringRole"
  create_monitoring_role = true

  apply_immediately = true

  # DB subnet group
  db_subnet_group_name = aws_db_subnet_group.this.name

  # DB parameter group
  family = "postgres15"

  # DB option group
  #major_engine_version = "15"

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name  = "password_encryption"
      value = "md5"
    }
  ]

  # options = [
  #   {
  #     option_name = "MARIADB_AUDIT_PLUGIN"

  #     option_settings = [
  #       {
  #         name  = "SERVER_AUDIT_EVENTS"
  #         value = "CONNECT"
  #       },
  #       {
  #         name  = "SERVER_AUDIT_FILE_ROTATIONS"
  #         value = "37"
  #       },
  #     ]
  #   },
  # ]
}
