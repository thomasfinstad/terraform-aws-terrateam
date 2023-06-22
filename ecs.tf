resource "aws_ecs_cluster" "this" {
  name = var.name
  tags = var.tags

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_service" "this" {
  name = "server"
  tags = var.tags

  enable_execute_command = true

  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = var.terrateam.target_group_arn
    container_name   = local.container_name
    container_port   = 8080
  }

  network_configuration {
    subnets          = var.terrateam.subnet_ids
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = false
  }

  capacity_provider_strategy { # forces replacement
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 100
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }
}

resource "aws_ecs_task_definition" "this" {
  family = var.name
  tags   = var.tags

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048

  task_role_arn      = aws_iam_role.ecs_task.arn
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = local.container_name
      image     = var.terrateam.image_url
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [for k, v in local.container_env : { name = k, value = v } if !startswith(v, "arn:")]

      secrets = [for k, v in local.container_env : { name = k, valueFrom = v } if startswith(v, "arn:")]

      logConfiguration = { # TODO make configurable
        logDriver = "awslogs",
        options = {
          awslogs-group         = "firelens-container",
          awslogs-region        = data.aws_region.current.name,
          awslogs-create-group  = "true",
          awslogs-stream-prefix = "firelens"
        }
      }
    }
  ])
}
