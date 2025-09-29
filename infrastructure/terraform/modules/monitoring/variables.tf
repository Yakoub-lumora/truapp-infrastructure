# ========================================
# Required Variables
# ========================================

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

# ========================================
# SNS Configuration
# ========================================

variable "alarm_email_endpoints" {
  description = "List of email addresses to receive alarm notifications"
  type        = list(string)
  default     = []
}

variable "enable_sns_encryption" {
  description = "Enable SNS topic encryption"
  type        = bool
  default     = true
}

# ========================================
# ALB Alarm Configuration
# ========================================

variable "enable_alb_alarms" {
  description = "Enable ALB CloudWatch alarms"
  type        = bool
  default     = true
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch dimensions"
  type        = string
  default     = ""
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix for CloudWatch dimensions"
  type        = string
  default     = ""
}

variable "alb_response_time_threshold" {
  description = "ALB response time threshold in seconds"
  type        = number
  default     = 1
}

variable "alb_5xx_threshold" {
  description = "ALB 5xx error threshold"
  type        = number
  default     = 10
}

# ========================================
# EC2 Alarm Configuration
# ========================================

variable "enable_ec2_alarms" {
  description = "Enable EC2 CloudWatch alarms"
  type        = bool
  default     = true
}

variable "asg_name" {
  description = "Auto Scaling Group name"
  type        = string
  default     = ""
}

variable "ec2_cpu_threshold" {
  description = "EC2 CPU utilization threshold percentage"
  type        = number
  default     = 80
}

variable "enable_memory_alarm" {
  description = "Enable EC2 memory alarm (requires CloudWatch Agent)"
  type        = bool
  default     = false
}

variable "ec2_memory_threshold" {
  description = "EC2 memory utilization threshold percentage"
  type        = number
  default     = 80
}

# ========================================
# RDS Alarm Configuration
# ========================================

variable "enable_rds_alarms" {
  description = "Enable RDS CloudWatch alarms"
  type        = bool
  default     = true
}

variable "rds_cluster_id" {
  description = "RDS cluster identifier"
  type        = string
  default     = ""
}

variable "rds_cpu_threshold" {
  description = "RDS CPU utilization threshold percentage"
  type        = number
  default     = 80
}

variable "rds_connections_threshold" {
  description = "RDS database connections threshold"
  type        = number
  default     = 80
}

variable "rds_freeable_memory_threshold" {
  description = "RDS freeable memory threshold in bytes"
  type        = number
  default     = 1073741824 # 1GB
}

# ========================================
# ElastiCache Redis Alarm Configuration
# ========================================

variable "enable_redis_alarms" {
  description = "Enable Redis CloudWatch alarms"
  type        = bool
  default     = true
}

variable "redis_replication_group_id" {
  description = "Redis replication group ID"
  type        = string
  default     = ""
}

variable "redis_cpu_threshold" {
  description = "Redis CPU utilization threshold percentage"
  type        = number
  default     = 75
}

variable "redis_memory_threshold" {
  description = "Redis memory utilization threshold percentage"
  type        = number
  default     = 80
}

# ========================================
# ECS Alarm Configuration
# ========================================

variable "enable_ecs_alarms" {
  description = "Enable ECS CloudWatch alarms"
  type        = bool
  default     = true
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = ""
}

variable "ecs_service_name" {
  description = "ECS service name"
  type        = string
  default     = ""
}

variable "ecs_cpu_threshold" {
  description = "ECS CPU utilization threshold percentage"
  type        = number
  default     = 80
}

variable "ecs_memory_threshold" {
  description = "ECS memory utilization threshold percentage"
  type        = number
  default     = 80
}

# ========================================
# Dashboard Configuration
# ========================================

variable "enable_dashboard" {
  description = "Enable CloudWatch dashboard"
  type        = bool
  default     = true
}

# ========================================
# CloudTrail Configuration
# ========================================

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail for audit logging"
  type        = bool
  default     = true
}

variable "cloudtrail_multi_region" {
  description = "Enable multi-region trail"
  type        = bool
  default     = true
}

variable "enable_cloudtrail_cloudwatch" {
  description = "Enable CloudTrail integration with CloudWatch Logs"
  type        = bool
  default     = true
}

variable "cloudtrail_cloudwatch_retention_days" {
  description = "CloudWatch Logs retention period in days for CloudTrail logs"
  type        = number
  default     = 90
}

variable "cloudtrail_log_retention_days" {
  description = "Number of days to retain CloudTrail logs in S3 before deletion"
  type        = number
  default     = 365
}

variable "cloudtrail_log_transition_days" {
  description = "Number of days before transitioning CloudTrail logs to Glacier"
  type        = number
  default     = 90
}

variable "cloudtrail_kms_key_id" {
  description = "KMS key ID for CloudTrail S3 bucket encryption (leave empty for AES256)"
  type        = string
  default     = ""
}

variable "cloudtrail_event_selectors" {
  description = "CloudTrail event selectors for advanced logging"
  type = list(object({
    read_write_type           = string
    include_management_events = bool
    data_resources = list(object({
      type   = string
      values = list(string)
    }))
  }))
  default = [
    {
      read_write_type           = "All"
      include_management_events = true
      data_resources            = []
    }
  ]
}

variable "cloudtrail_cloudwatch_role_arn" {
  description = "IAM role ARN for CloudTrail to write to CloudWatch Logs"
  type        = string
  default     = ""
}

# ========================================
# Tags
# ========================================

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
