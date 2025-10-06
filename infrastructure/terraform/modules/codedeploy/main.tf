# CodeDeploy Application
resource "aws_codedeploy_app" "main" {
  name             = "${var.project_name}-${var.environment}"
  compute_platform = "Server"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-codedeploy-app"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Deployment"
    },
    var.tags
  )
}

# SNS Topic for Deployment Notifications
resource "aws_sns_topic" "deployments" {
  count = var.enable_deployment_notifications ? 1 : 0

  name              = "${var.project_name}-${var.environment}-deployments"
  display_name      = "${var.project_name} ${var.environment} Deployments"
  kms_master_key_id = var.enable_sns_encryption ? "alias/aws/sns" : null

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-deployments-topic"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Deployment"
    },
    var.tags
  )
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "deployment_email" {
  count = var.enable_deployment_notifications ? length(var.notification_endpoints) : 0

  topic_arn = aws_sns_topic.deployments[0].arn
  protocol  = "email"
  endpoint  = var.notification_endpoints[count.index]
}

# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "main" {
  app_name               = aws_codedeploy_app.main.name
  deployment_group_name  = "${var.project_name}-${var.environment}-deployment-group"
  service_role_arn       = var.codedeploy_service_role_arn
  deployment_config_name = var.deployment_config_name

  autoscaling_groups = var.autoscaling_groups

  load_balancer_info {
    target_group_info {
      name = var.target_group_name
    }
  }

  deployment_style {
    deployment_option = var.enable_traffic_control ? "WITH_TRAFFIC_CONTROL" : "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = var.deployment_type
  }

  auto_rollback_configuration {
    enabled = var.enable_auto_rollback
    events  = var.auto_rollback_events
  }

  dynamic "alarm_configuration" {
    for_each = length(var.alarm_names) > 0 ? [1] : []
    content {
      enabled                   = var.enable_alarm_monitoring
      alarms                    = var.alarm_names
      ignore_poll_alarm_failure = var.ignore_poll_alarm_failure
    }
  }

  dynamic "blue_green_deployment_config" {
    for_each = var.deployment_type == "BLUE_GREEN" ? [1] : []
    content {
      terminate_blue_instances_on_deployment_success {
        action                           = var.blue_green_terminate_action
        termination_wait_time_in_minutes = var.blue_green_termination_wait_time
      }

      deployment_ready_option {
        action_on_timeout    = var.deployment_ready_timeout_action
        wait_time_in_minutes = var.deployment_ready_timeout_action == "STOP_DEPLOYMENT" ? var.deployment_ready_wait_time : null
      }

      green_fleet_provisioning_option {
        action = var.green_fleet_provisioning_action
      }
    }
  }

  dynamic "ec2_tag_filter" {
    for_each = var.ec2_tag_filters
    content {
      key   = ec2_tag_filter.value.key
      type  = ec2_tag_filter.value.type
      value = ec2_tag_filter.value.value
    }
  }

  dynamic "trigger_configuration" {
    for_each = var.enable_deployment_notifications ? [1] : []
    content {
      trigger_events     = var.trigger_events
      trigger_name       = "${var.project_name}-${var.environment}-deployment-trigger"
      trigger_target_arn = aws_sns_topic.deployments[0].arn
    }
  }

  outdated_instances_strategy = var.outdated_instances_strategy

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-deployment-group"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Deployment"
    },
    var.tags
  )
}

# CloudWatch Alarm for Deployment Failures
resource "aws_cloudwatch_metric_alarm" "deployment_failures" {
  count = var.enable_deployment_failure_alarm ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-codedeploy-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FailedDeployments"
  namespace           = "AWS/CodeDeploy"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alert when CodeDeploy deployment fails"
  treat_missing_data  = "notBreaching"

  alarm_actions = var.enable_deployment_notifications ? [aws_sns_topic.deployments[0].arn] : []
  ok_actions    = var.enable_deployment_notifications ? [aws_sns_topic.deployments[0].arn] : []

  dimensions = {
    ApplicationName     = aws_codedeploy_app.main.name
    DeploymentGroupName = aws_codedeploy_deployment_group.main.deployment_group_name
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-codedeploy-failure-alarm"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# S3 Bucket for Deployment Artifacts
resource "aws_s3_bucket" "deployments" {
  count = var.create_deployment_bucket ? 1 : 0

  bucket_prefix = "${var.project_name}-${var.environment}-deployments-"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-deployments-bucket"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Deployment"
    },
    var.tags
  )
}

resource "aws_s3_bucket_versioning" "deployments" {
  count = var.create_deployment_bucket ? 1 : 0

  bucket = aws_s3_bucket.deployments[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "deployments" {
  count = var.create_deployment_bucket ? 1 : 0

  bucket = aws_s3_bucket.deployments[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "deployments" {
  count = var.create_deployment_bucket ? 1 : 0

  bucket = aws_s3_bucket.deployments[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "deployments" {
  count = var.create_deployment_bucket ? 1 : 0

  bucket = aws_s3_bucket.deployments[0].id

  rule {
    id     = "cleanup-old-deployments"
    status = "Enabled"

    expiration {
      days = var.deployment_artifact_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.deployment_artifact_noncurrent_version_retention_days
    }
  }
}
