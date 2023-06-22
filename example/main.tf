terraform {
  required_version = ">= 1.4.0"
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    region         = "..."
    bucket         = "..."
    dynamodb_table = "..."
    key            = "..."
    role_arn       = "..."
  }
}

provider "aws" {
  region = "..."

  assume_role {
    role_arn     = "..."
    session_name = "..."
  }

  default_tags {
    tags = local.tags
  }
}

locals {
  name            = "terrateam-example"
  tags            = { "tag" = "value" }
  route53_zone_id = "my-r53-zone-id"
}

module "prerequisites" {
  source = "./prerequisites"

  name            = local.name
  route53_zone_id = local.route53_zone_id
}

data "aws_secretsmanager_secret" "github_app" {
  # Manually created
  name = "terrateam-example/github-app"
}

###
# Network access
resource "aws_security_group_rule" "ecs_egress_secretsmanager" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = module.terrateam.security_group_id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_egress_rds" {
  security_group_id = module.terrateam.security_group_id
  type              = "egress"

  from_port = module.prerequisites.rds.port
  to_port   = module.prerequisites.rds.port
  protocol  = "tcp"

  source_security_group_id = module.prerequisites.rds.security_group
}

resource "aws_security_group_rule" "rds_ingress_ecs" {
  security_group_id = module.prerequisites.rds.security_group
  type              = "ingress"

  from_port = module.prerequisites.rds.port
  to_port   = module.prerequisites.rds.port
  protocol  = "tcp"

  source_security_group_id = module.terrateam.security_group_id
}

resource "aws_security_group_rule" "alb_egress_ecs" {
  from_port                = 8080
  protocol                 = "tcp"
  security_group_id        = module.prerequisites.loadbalancer.security_group
  to_port                  = 8080
  type                     = "egress"
  source_security_group_id = module.terrateam.security_group_id
}

resource "aws_security_group_rule" "ecs_ingress_alb" {
  from_port                = 8080
  protocol                 = "tcp"
  security_group_id        = module.terrateam.security_group_id
  to_port                  = 8080
  type                     = "ingress"
  source_security_group_id = module.prerequisites.loadbalancer.security_group
}

###
# Terrateam

module "terrateam" {
  source = "../"

  name = local.name
  tags = local.tags

  terrateam = {
    api_base         = "https://${module.prerequisites.endpoint}/api"
    target_group_arn = module.prerequisites.loadbalancer.target_group_arn
    subnet_ids       = module.prerequisites.vpc.subnets.private
    iam_role_arn     = "string"
  }

  database = {
    host     = module.prerequisites.rds.host
    port     = module.prerequisites.rds.port
    name     = module.prerequisites.rds.name
    username = "${module.prerequisites.rds.master_user.secret_arn}:username"
    password = "${module.prerequisites.rds.master_user.secret_arn}:password"
  }

  github = {
    app_id            = "${data.aws_secretsmanager_secret.github_app.arn}:GITHUB_APP_ID"
    app_client_id     = "${data.aws_secretsmanager_secret.github_app.arn}:GITHUB_APP_CLIENT_ID"
    app_client_secret = "${data.aws_secretsmanager_secret.github_app.arn}:GITHUB_APP_CLIENT_SECRET"
    app_pem           = "${data.aws_secretsmanager_secret.github_app.arn}:GITHUB_APP_PEM"
    webhook_secret    = "${data.aws_secretsmanager_secret.github_app.arn}:GITHUB_WEBHOOK_SECRET"
  }
}
