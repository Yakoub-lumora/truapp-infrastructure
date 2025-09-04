# ALB Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-alb-sg"
      Environment = var.environment
      Project     = var.project_name
      Component   = "LoadBalancer"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS from internet"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-alb-https-in"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP from internet (redirect to HTTPS)"

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-alb-http-in"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow traffic to Next.js app"

  from_port                    = 3000
  to_port                      = 3000
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2_app.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-alb-to-app-out"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# EC2 App Security Group
resource "aws_security_group" "ec2_app" {
  name_prefix = "${var.project_name}-${var.environment}-app-"
  description = "Security group for Next.js app instances (ASG)"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-app-sg"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Application"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id = aws_security_group.ec2_app.id
  description       = "Allow traffic from ALB"

  from_port                    = 3000
  to_port                      = 3000
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-app-from-alb-in"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "app_to_rds" {
  security_group_id = aws_security_group.ec2_app.id
  description       = "Allow PostgreSQL connection to RDS"

  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.rds.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-app-to-rds-out"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "app_to_elasticache" {
  security_group_id = aws_security_group.ec2_app.id
  description       = "Allow Redis connection to ElastiCache"

  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.elasticache.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-app-to-redis-out"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "app_to_internet_https" {
  security_group_id = aws_security_group.ec2_app.id
  description       = "Allow HTTPS to internet"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-app-https-out"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "app_to_internet_http" {
  security_group_id = aws_security_group.ec2_app.id
  description       = "Allow HTTP to internet"

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-app-http-out"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# Bastion Security Group
resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-${var.environment}-bastion-"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-bastion-sg"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Bastion"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  count = length(var.allowed_ssh_cidr) > 0 ? 1 : 0

  security_group_id = aws_security_group.bastion.id
  description       = "Allow SSH from allowed IPs"

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = var.allowed_ssh_cidr[count.index]

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-bastion-ssh-in"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "bastion_to_rds" {
  security_group_id = aws_security_group.bastion.id
  description       = "Allow PostgreSQL connection for troubleshooting"

  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.rds.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-bastion-to-rds-out"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "bastion_to_elasticache" {
  security_group_id = aws_security_group.bastion.id
  description       = "Allow Redis connection for troubleshooting"

  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.elasticache.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-bastion-to-redis-out"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "bastion_to_internet_https" {
  security_group_id = aws_security_group.bastion.id
  description       = "Allow HTTPS for updates"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-bastion-https-out"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "bastion_to_internet_http" {
  security_group_id = aws_security_group.bastion.id
  description       = "Allow HTTP for updates"

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-bastion-http-out"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# ECS Workers Security Group
resource "aws_security_group" "ecs_workers" {
  name_prefix = "${var.project_name}-${var.environment}-workers-"
  description = "Security group for ECS worker tasks"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-workers-sg"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Workers"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_vpc_security_group_egress_rule" "workers_to_elasticache" {
  security_group_id = aws_security_group.ecs_workers.id
  description       = "Allow Redis connection"

  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.elasticache.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-workers-to-redis-out"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "workers_to_rds" {
  security_group_id = aws_security_group.ecs_workers.id
  description       = "Allow PostgreSQL connection"

  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.rds.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-workers-to-rds-out"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "workers_to_internet_https" {
  security_group_id = aws_security_group.ecs_workers.id
  description       = "Allow HTTPS to internet"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-workers-https-out"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-"
  description = "Security group for RDS Aurora PostgreSQL"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-rds-sg"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Database"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_vpc_security_group_ingress_rule" "rds_from_app" {
  security_group_id = aws_security_group.rds.id
  description       = "Allow PostgreSQL from Next.js app"

  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2_app.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-rds-from-app-in"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_workers" {
  security_group_id = aws_security_group.rds.id
  description       = "Allow PostgreSQL from ECS workers"

  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_workers.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-rds-from-workers-in"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_bastion" {
  security_group_id = aws_security_group.rds.id
  description       = "Allow PostgreSQL from bastion"

  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-rds-from-bastion-in"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# ElastiCache Security Group
resource "aws_security_group" "elasticache" {
  name_prefix = "${var.project_name}-${var.environment}-redis-"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-redis-sg"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Cache"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_vpc_security_group_ingress_rule" "elasticache_from_app" {
  security_group_id = aws_security_group.elasticache.id
  description       = "Allow Redis from Next.js app"

  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2_app.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-redis-from-app-in"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "elasticache_from_workers" {
  security_group_id = aws_security_group.elasticache.id
  description       = "Allow Redis from ECS workers"

  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_workers.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-redis-from-workers-in"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "elasticache_from_bastion" {
  security_group_id = aws_security_group.elasticache.id
  description       = "Allow Redis from bastion"

  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-redis-from-bastion-in"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# IAM Role for EC2 Instances
resource "aws_iam_role" "ec2_app" {
  name_prefix = "${var.project_name}-${var.environment}-ec2-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-ec2-role"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# IAM Policy for S3 Access
resource "aws_iam_role_policy" "s3_access" {
  name_prefix = "${var.project_name}-${var.environment}-s3-"
  role        = aws_iam_role.ec2_app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = var.s3_bucket_arn != "" ? [
          "${var.s3_bucket_arn}",
          "${var.s3_bucket_arn}/*"
        ] : ["*"]
      }
    ]
  })
}

# IAM Policy for CloudWatch Logs
resource "aws_iam_role_policy" "cloudwatch_logs" {
  name_prefix = "${var.project_name}-${var.environment}-logs-"
  role        = aws_iam_role.ec2_app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# IAM Policy for SSM Parameter Store
resource "aws_iam_role_policy" "ssm_parameters" {
  name_prefix = "${var.project_name}-${var.environment}-ssm-"
  role        = aws_iam_role.ec2_app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/${var.project_name}/${var.environment}/*"
      }
    ]
  })
}

# Attach SSM Managed Policy for Session Manager
resource "aws_iam_role_policy_attachment" "ssm_managed_policy" {
  role       = aws_iam_role.ec2_app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_app" {
  name_prefix = "${var.project_name}-${var.environment}-ec2-"
  role        = aws_iam_role.ec2_app.name

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-ec2-profile"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# IAM Role for ECS Tasks
resource "aws_iam_role" "ecs_task" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-task-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-ecs-task-role"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# IAM Policy for ECS Task S3 Access
resource "aws_iam_role_policy" "ecs_s3_access" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-s3-"
  role        = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = var.s3_bucket_arn != "" ? [
          "${var.s3_bucket_arn}",
          "${var.s3_bucket_arn}/*"
        ] : ["*"]
      }
    ]
  })
}

# IAM Task Execution Role (for ECS to pull images, write logs)
resource "aws_iam_role" "ecs_task_execution" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-exec-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-ecs-exec-role"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# Attach ECS Task Execution Policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Execution - SSM Parameter Store Access
resource "aws_iam_role_policy" "ecs_task_execution_ssm" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-exec-ssm-"
  role        = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/${var.project_name}/${var.environment}/*"
      }
    ]
  })
}

# CloudTrail Role for CloudWatch Logs
resource "aws_iam_role" "cloudtrail_cloudwatch" {
  count = var.enable_cloudtrail_cloudwatch ? 1 : 0

  name_prefix = "${var.project_name}-${var.environment}-cloudtrail-cw-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-cloudtrail-cw-role"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Audit"
    },
    var.tags
  )
}

# IAM Policy for CloudTrail to write to CloudWatch Logs
resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  count = var.enable_cloudtrail_cloudwatch ? 1 : 0

  name_prefix = "${var.project_name}-${var.environment}-cloudtrail-cw-"
  role        = aws_iam_role.cloudtrail_cloudwatch[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogsWrite"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = var.cloudtrail_log_group_arn != "" ? "${var.cloudtrail_log_group_arn}:*" : "*"
      }
    ]
  })
}

# CodeDeploy Service Role
resource "aws_iam_role" "codedeploy" {
  name_prefix = "${var.project_name}-${var.environment}-codedeploy-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-codedeploy-role"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Deployment"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}
