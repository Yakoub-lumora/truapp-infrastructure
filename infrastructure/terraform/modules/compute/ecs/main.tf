# ECR Repository

resource "aws_ecr_repository" "workers" {
  name                 = "${var.project_name}-${var.environment}-workers"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-workers-ecr"
      Environment = var.environment
      Project     = var.project_name
      Component   = "ContainerRegistry"
      Purpose     = "TruShot worker images"
    },
    var.tags
  )
}

# ECR Lifecycle Policy - Keep last 10 images
resource "aws_ecr_lifecycle_policy" "workers" {
  repository = aws_ecr_repository.workers.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECS Cluster

resource "aws_ecs_cluster" "workers" {
  name = "${var.project_name}-${var.environment}-workers"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-workers-cluster"
      Environment = var.environment
      Project     = var.project_name
      Component   = "ECS"
      Purpose     = "TruShot worker cluster"
    },
    var.tags
  )
}

# CloudWatch Log Group

resource "aws_cloudwatch_log_group" "workers" {
  name              = "/ecs/${var.project_name}-${var.environment}-workers"
  retention_in_days = var.log_retention_days

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-workers-logs"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Logging"
    },
    var.tags
  )
}

# ECS Task Definition

resource "aws_ecs_task_definition" "workers" {
  family                   = "${var.project_name}-${var.environment}-workers"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "worker"
      image     = "${aws_ecr_repository.workers.repository_url}:${var.worker_image_tag}"
      essential = true

      # Basic environment variables (non-sensitive)
      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment == "prod" ? "production" : "development"
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "PROJECT_NAME"
          value = var.project_name
        },
        {
          name  = "ENVIRONMENT"
          value = var.environment
        }
      ]

      # Dynamically load all sensitive variables from SSM Parameter Store
      secrets = local.ssm_secrets

      # Health check configuration matching docker-compose.yml
      healthCheck = {
        command     = ["CMD-SHELL", "npx tsx lib/queue/worker-service.ts health || exit 1"]
        interval    = 30
        timeout     = 15
        retries     = 3
        startPeriod = 60
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.workers.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "worker"
        }
      }
    }
  ])

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-workers-task"
      Environment = var.environment
      Project     = var.project_name
      Component   = "ECS"
    },
    var.tags
  )
}

# ECS Service

resource "aws_ecs_service" "workers" {
  name            = "${var.project_name}-${var.environment}-workers"
  cluster         = aws_ecs_cluster.workers.id
  task_definition = aws_ecs_task_definition.workers.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  platform_version = "LATEST"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  enable_execute_command = var.enable_execute_command

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-workers-service"
      Environment = var.environment
      Project     = var.project_name
      Component   = "ECS"
    },
    var.tags
  )

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Auto Scaling

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.workers.name}/${aws_ecs_service.workers.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU-based scaling
resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  name               = "${var.project_name}-${var.environment}-workers-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.cpu_target_value
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Memory-based scaling
resource "aws_appautoscaling_policy" "ecs_memory_policy" {
  count = var.enable_memory_scaling ? 1 : 0

  name               = "${var.project_name}-${var.environment}-workers-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = var.memory_target_value
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Data Sources

data "aws_caller_identity" "current" {}
