# ========================================
# Monitoring Module
# ========================================
# This module provisions:
# - SNS topics for alarm notifications
# - CloudWatch Alarms for all services
# - CloudWatch Dashboard
# - X-Ray tracing configuration

# ========================================
# SNS Topics for Notifications
# ========================================

resource "aws_sns_topic" "alarms" {
  name              = "${var.project_name}-${var.environment}-alarms"
  display_name      = "${var.project_name} ${var.environment} Alarms"
  kms_master_key_id = var.enable_sns_encryption ? "alias/aws/sns" : null

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-alarms-topic"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Monitoring"
    },
    var.tags
  )
}

# SNS Topic Subscription (Email)
resource "aws_sns_topic_subscription" "alarm_email" {
  count = length(var.alarm_email_endpoints)

  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email_endpoints[count.index]
}

# ========================================
# ALB CloudWatch Alarms
# ========================================

resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  count = var.enable_alb_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-alb-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = var.alb_response_time_threshold
  alarm_description   = "ALB target response time is too high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-alb-response-time-alarm"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  count = var.enable_alb_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-alb-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "ALB has unhealthy targets"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-alb-unhealthy-alarm"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  count = var.enable_alb_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-alb-high-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alb_5xx_threshold
  alarm_description   = "ALB 5xx errors are too high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-alb-5xx-alarm"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# ========================================
# EC2 Auto Scaling Group Alarms
# ========================================

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  count = var.enable_ec2_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.ec2_cpu_threshold
  alarm_description   = "EC2 CPU utilization is too high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-ec2-cpu-alarm"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_cloudwatch_metric_alarm" "ec2_memory_high" {
  count = var.enable_ec2_alarms && var.enable_memory_alarm ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-ec2-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = var.ec2_memory_threshold
  alarm_description   = "EC2 memory utilization is too high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-ec2-memory-alarm"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# ========================================
# RDS Aurora Alarms
# ========================================

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  count = var.enable_rds_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.rds_cpu_threshold
  alarm_description   = "RDS CPU utilization is too high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBClusterIdentifier = var.rds_cluster_id
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-rds-cpu-alarm"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  count = var.enable_rds_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-rds-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.rds_connections_threshold
  alarm_description   = "RDS database connections are too high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBClusterIdentifier = var.rds_cluster_id
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-rds-connections-alarm"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_cloudwatch_metric_alarm" "rds_freeable_memory_low" {
  count = var.enable_rds_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-rds-low-memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.rds_freeable_memory_threshold
  alarm_description   = "RDS freeable memory is too low"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBClusterIdentifier = var.rds_cluster_id
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-rds-memory-alarm"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# ========================================
# ElastiCache Redis Alarms
# ========================================

resource "aws_cloudwatch_metric_alarm" "redis_cpu_high" {
  count = var.enable_redis_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-redis-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = var.redis_cpu_threshold
  alarm_description   = "Redis CPU utilization is too high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    ReplicationGroupId = var.redis_replication_group_id
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-redis-cpu-alarm"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_cloudwatch_metric_alarm" "redis_memory_high" {
  count = var.enable_redis_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-redis-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = var.redis_memory_threshold
  alarm_description   = "Redis memory utilization is too high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    ReplicationGroupId = var.redis_replication_group_id
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-redis-memory-alarm"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# ========================================
# ECS Fargate Alarms
# ========================================

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  count = var.enable_ecs_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-ecs-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.ecs_cpu_threshold
  alarm_description   = "ECS CPU utilization is too high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-ecs-cpu-alarm"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  count = var.enable_ecs_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-ecs-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.ecs_memory_threshold
  alarm_description   = "ECS memory utilization is too high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-ecs-memory-alarm"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# ========================================
# CloudWatch Dashboard
# ========================================

resource "aws_cloudwatch_dashboard" "main" {
  count = var.enable_dashboard ? 1 : 0

  dashboard_name = "${var.project_name}-${var.environment}-overview"

  dashboard_body = jsonencode({
    widgets = [
      # ALB Metrics
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average", label = "Response Time" }],
            [".", "RequestCount", { stat = "Sum", label = "Request Count" }],
            [".", "HTTPCode_Target_5XX_Count", { stat = "Sum", label = "5XX Errors" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB Performance"
          period  = 300
        }
      },
      # EC2 Metrics
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", { stat = "Average", label = "CPU Usage" }],
            ["CWAgent", "mem_used_percent", { stat = "Average", label = "Memory Usage" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "EC2 Performance"
          period  = 300
        }
      },
      # RDS Metrics
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", { stat = "Average", label = "CPU Usage" }],
            [".", "DatabaseConnections", { stat = "Average", label = "Connections" }],
            [".", "FreeableMemory", { stat = "Average", label = "Free Memory" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "RDS Performance"
          period  = 300
        }
      },
      # Redis Metrics
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ElastiCache", "CPUUtilization", { stat = "Average", label = "CPU Usage" }],
            [".", "DatabaseMemoryUsagePercentage", { stat = "Average", label = "Memory Usage" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Redis Performance"
          period  = 300
        }
      },
      # ECS Metrics
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", { stat = "Average", label = "CPU Usage" }],
            [".", "MemoryUtilization", { stat = "Average", label = "Memory Usage" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ECS Workers Performance"
          period  = 300
        }
      }
    ]
  })
}

# ========================================
# CloudTrail - Audit Logging
# ========================================

# S3 Bucket for CloudTrail Logs
resource "aws_s3_bucket" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  bucket_prefix = "${var.project_name}-${var.environment}-cloudtrail-"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-cloudtrail-bucket"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Audit"
    },
    var.tags
  )
}

# Enable versioning for CloudTrail bucket
resource "aws_s3_bucket_versioning" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption for CloudTrail bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.cloudtrail_kms_key_id != "" ? "aws:kms" : "AES256"
      kms_master_key_id = var.cloudtrail_kms_key_id != "" ? var.cloudtrail_kms_key_id : null
    }
  }
}

# Block public access to CloudTrail bucket
resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for CloudTrail logs
resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    id     = "cloudtrail-log-retention"
    status = "Enabled"

    transition {
      days          = var.cloudtrail_log_transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.cloudtrail_log_retention_days
    }
  }
}

# S3 Bucket Policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail[0].arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail[0].arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudTrail
resource "aws_cloudtrail" "main" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail[0].id
  include_global_service_events = true
  is_multi_region_trail         = var.cloudtrail_multi_region
  enable_log_file_validation    = true
  enable_logging                = true

  # Send CloudTrail logs to CloudWatch Logs
  cloud_watch_logs_group_arn = var.enable_cloudtrail_cloudwatch ? "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*" : null
  cloud_watch_logs_role_arn  = var.enable_cloudtrail_cloudwatch ? var.cloudtrail_cloudwatch_role_arn : null

  # Event selectors for detailed logging
  dynamic "event_selector" {
    for_each = var.cloudtrail_event_selectors
    content {
      read_write_type           = event_selector.value.read_write_type
      include_management_events = event_selector.value.include_management_events

      dynamic "data_resource" {
        for_each = event_selector.value.data_resources
        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-cloudtrail"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Audit"
    },
    var.tags
  )

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

# CloudWatch Log Group for CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  count = var.enable_cloudtrail && var.enable_cloudtrail_cloudwatch ? 1 : 0

  name              = "/aws/cloudtrail/${var.project_name}-${var.environment}"
  retention_in_days = var.cloudtrail_cloudwatch_retention_days

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-cloudtrail-logs"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Audit"
    },
    var.tags
  )
}
