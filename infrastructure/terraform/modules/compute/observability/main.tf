# EFS File System for Prometheus Storage

resource "aws_efs_file_system" "prometheus" {
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-prometheus-efs"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Prometheus"
    },
    var.tags
  )
}

# EFS Mount Targets for Multi-AZ Support

resource "aws_efs_mount_target" "prometheus" {
  count = length(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.prometheus.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

# Security Groups

resource "aws_security_group" "efs" {
  name        = "${var.project_name}-${var.environment}-prometheus-efs"
  description = "Security group for Prometheus EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.observability_tasks.id]
    description     = "NFS from observability tasks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-prometheus-efs-sg"
      Environment = var.environment
      Project     = var.project_name
      Component   = "SecurityGroups"
    },
    var.tags
  )
}

resource "aws_security_group" "observability_tasks" {
  name        = "${var.project_name}-${var.environment}-observability-tasks"
  description = "Security group for Prometheus and Grafana tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [aws_security_group.observability_alb.id]
    description     = "Prometheus API from ALB"
  }

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.observability_alb.id]
    description     = "Grafana from ALB"
  }

  ingress {
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
    description     = "Metrics from app service"
  }

  ingress {
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [var.worker_security_group_id]
    description     = "Metrics from worker service"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-observability-tasks-sg"
      Environment = var.environment
      Project     = var.project_name
      Component   = "SecurityGroups"
    },
    var.tags
  )
}

resource "aws_security_group" "observability_alb" {
  name        = "${var.project_name}-${var.environment}-observability-alb"
  description = "Security group for observability ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.observability_allowed_cidr
    description = "Prometheus API"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.observability_allowed_cidr
    description = "Grafana HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.observability_allowed_cidr
    description = "Grafana HTTPS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-observability-alb-sg"
      Environment = var.environment
      Project     = var.project_name
      Component   = "SecurityGroups"
    },
    var.tags
  )
}

# CloudWatch Log Groups

resource "aws_cloudwatch_log_group" "prometheus" {
  name              = "/ecs/${var.project_name}-${var.environment}-prometheus"
  retention_in_days = var.log_retention_days

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-prometheus-logs"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Logging"
    },
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/${var.project_name}-${var.environment}-grafana"
  retention_in_days = var.log_retention_days

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-grafana-logs"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Logging"
    },
    var.tags
  )
}

# IAM Policies

resource "aws_iam_role_policy" "prometheus_efs" {
  name = "${var.project_name}-${var.environment}-prometheus-efs"
  role = var.ecs_task_role_arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets"
        ]
        Resource = "*"
      }
    ]
  })
}

# ECS Task Definitions

resource "aws_ecs_task_definition" "prometheus" {
  family                   = "${var.project_name}-${var.environment}-prometheus"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.prometheus_cpu
  memory                   = var.prometheus_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "prometheus"
      image     = "PROMETHEUS_IMAGE_PLACEHOLDER"
      essential = true
      portMappings = [
        {
          containerPort = 9090
          hostPort      = 9090
          protocol      = "tcp"
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "prometheus-storage"
          containerPath = "/prometheus"
          readOnly      = false
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.prometheus.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "prometheus"
        }
      }
    }
  ])

  volume {
    name = "prometheus-storage"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.prometheus.id
      root_directory = "/prometheus"
    }
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-prometheus-task"
      Environment = var.environment
      Project     = var.project_name
      Component   = "ECS"
    },
    var.tags
  )

  depends_on = [
    aws_efs_mount_target.prometheus,
    aws_iam_role_policy.prometheus_efs
  ]
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.project_name}-${var.environment}-grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.grafana_cpu
  memory                   = var.grafana_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "GRAFANA_IMAGE_PLACEHOLDER"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "grafana"
        }
      }
    }
  ])

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-grafana-task"
      Environment = var.environment
      Project     = var.project_name
      Component   = "ECS"
    },
    var.tags
  )
}

# ECS Services

resource "aws_ecs_service" "prometheus" {
  name            = "${var.project_name}-${var.environment}-prometheus"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = var.prometheus_desired_count
  launch_type     = "FARGATE"

  platform_version = "LATEST"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.observability_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.prometheus.arn
    container_name   = "prometheus"
    container_port   = 9090
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-prometheus-service"
      Environment = var.environment
      Project     = var.project_name
      Component   = "ECS"
    },
    var.tags
  )

  depends_on = [aws_lb_listener.prometheus]
}

resource "aws_ecs_service" "grafana" {
  name            = "${var.project_name}-${var.environment}-grafana"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_desired_count
  launch_type     = "FARGATE"

  platform_version = "LATEST"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.observability_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-grafana-service"
      Environment = var.environment
      Project     = var.project_name
      Component   = "ECS"
    },
    var.tags
  )

  depends_on = [aws_lb_listener.grafana]
}

# Load Balancer Target Groups

resource "aws_lb_target_group" "prometheus" {
  name        = "${var.project_name}-${var.environment}-prometheus"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/-/healthy"
    matcher             = "200"
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-prometheus-tg"
      Environment = var.environment
      Project     = var.project_name
      Component   = "LoadBalancing"
    },
    var.tags
  )
}

resource "aws_lb_target_group" "grafana" {
  name        = "${var.project_name}-${var.environment}-grafana"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/api/health"
    matcher             = "200"
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-grafana-tg"
      Environment = var.environment
      Project     = var.project_name
      Component   = "LoadBalancing"
    },
    var.tags
  )
}

# Load Balancer Listeners

resource "aws_lb_listener" "prometheus" {
  load_balancer_arn = var.observability_alb_arn
  port              = 9090
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus.arn
  }
}

resource "aws_lb_listener" "grafana" {
  load_balancer_arn = var.observability_alb_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}
