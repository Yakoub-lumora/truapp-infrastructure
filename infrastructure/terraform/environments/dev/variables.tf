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
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway instead of one per AZ"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH into bastion"
  type        = list(string)
  default     = []
}

# Database Variables
variable "database_name" {
  description = "Name of the default database"
  type        = string
  default     = "trushot"
}

variable "master_username" {
  description = "Master username for database"
  type        = string
  default     = "postgres"
}

variable "master_password" {
  description = "Master password for database"
  type        = string
  sensitive   = true
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "Instance class for Aurora instances"
  type        = string
  default     = "db.t3.medium"
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "create_read_replica" {
  description = "Create a read replica instance"
  type        = bool
  default     = false
}

variable "redis_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_cache_nodes" {
  description = "Number of cache nodes"
  type        = number
  default     = 2
}

variable "enable_enhanced_monitoring" {
  description = "Enable enhanced monitoring"
  type        = bool
  default     = false
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Log types to export to CloudWatch"
  type        = list(string)
  default     = ["postgresql"]
}

# Compute Variables
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 30
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "asg_min_size" {
  description = "ASG minimum size"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "ASG maximum size"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "ASG desired capacity"
  type        = number
  default     = 2
}

variable "cpu_target_value" {
  description = "Target CPU utilization for scaling"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Target memory utilization for scaling"
  type        = number
  default     = 80
}

variable "enable_memory_scaling" {
  description = "Enable memory-based auto scaling"
  type        = bool
  default     = false
}

variable "enable_alb_deletion_protection" {
  description = "Enable ALB deletion protection"
  type        = bool
  default     = false
}

# ECS Variables
variable "ecs_task_cpu" {
  description = "CPU units for ECS task"
  type        = string
  default     = "512"
}

variable "ecs_task_memory" {
  description = "Memory for ECS task in MB"
  type        = string
  default     = "1024"
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "ecs_min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 1
}

variable "ecs_max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 2
}

variable "ecs_worker_image_tag" {
  description = "Docker image tag for worker"
  type        = string
  default     = "latest"
}

variable "ecs_enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = false
}

variable "ecs_enable_execute_command" {
  description = "Enable ECS Exec for debugging"
  type        = bool
  default     = true
}

variable "ecs_cpu_target_value" {
  description = "Target CPU utilization for ECS auto scaling"
  type        = number
  default     = 70
}

variable "ecs_memory_target_value" {
  description = "Target memory utilization for ECS auto scaling"
  type        = number
  default     = 80
}

variable "ecs_enable_memory_scaling" {
  description = "Enable memory-based auto scaling for ECS"
  type        = bool
  default     = false
}

variable "ecs_log_retention_days" {
  description = "CloudWatch log retention in days for ECS"
  type        = number
  default     = 7
}

# Storage Variables
variable "bucket_name" {
  description = "Name of the S3 bucket for image storage"
  type        = string
}

variable "enable_s3_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "enable_s3_lifecycle_rules" {
  description = "Enable S3 lifecycle rules"
  type        = bool
  default     = true
}

variable "temp_files_expiration_days" {
  description = "Days before temp files are deleted"
  type        = number
  default     = 7
}

variable "glacier_transition_days" {
  description = "Days before old versions transition to Glacier"
  type        = number
  default     = 30
}

variable "old_version_expiration_days" {
  description = "Days before old versions are deleted"
  type        = number
  default     = 90
}

variable "allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
}

variable "cloudfront_aliases" {
  description = "CloudFront CNAMEs"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
  default     = ""
}

variable "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  type        = string
  default     = ""
}

variable "enable_cloudfront_logging" {
  description = "Enable CloudFront logging"
  type        = bool
  default     = false
}

variable "cloudfront_logging_bucket" {
  description = "S3 bucket for CloudFront logs"
  type        = string
  default     = ""
}

# Monitoring Variables
variable "alarm_email_endpoints" {
  description = "List of email addresses for alarm notifications"
  type        = list(string)
  default     = []
}

variable "enable_sns_encryption" {
  description = "Enable SNS topic encryption"
  type        = bool
  default     = true
}

variable "enable_alb_alarms" {
  description = "Enable ALB CloudWatch alarms"
  type        = bool
  default     = true
}

variable "alb_response_time_threshold" {
  description = "ALB response time threshold in seconds"
  type        = number
  default     = 2
}

variable "alb_5xx_threshold" {
  description = "ALB 5xx error threshold"
  type        = number
  default     = 20
}

variable "enable_ec2_alarms" {
  description = "Enable EC2 CloudWatch alarms"
  type        = bool
  default     = true
}

variable "ec2_cpu_threshold" {
  description = "EC2 CPU threshold percentage"
  type        = number
  default     = 85
}

variable "enable_memory_alarm" {
  description = "Enable EC2 memory alarm"
  type        = bool
  default     = false
}

variable "ec2_memory_threshold" {
  description = "EC2 memory threshold percentage"
  type        = number
  default     = 85
}

variable "enable_rds_alarms" {
  description = "Enable RDS CloudWatch alarms"
  type        = bool
  default     = true
}

variable "rds_cpu_threshold" {
  description = "RDS CPU threshold percentage"
  type        = number
  default     = 85
}

variable "rds_connections_threshold" {
  description = "RDS connections threshold"
  type        = number
  default     = 80
}

variable "rds_freeable_memory_threshold" {
  description = "RDS freeable memory threshold in bytes"
  type        = number
  default     = 1073741824
}

variable "enable_redis_alarms" {
  description = "Enable Redis CloudWatch alarms"
  type        = bool
  default     = true
}

variable "redis_cpu_threshold" {
  description = "Redis CPU threshold percentage"
  type        = number
  default     = 80
}

variable "redis_memory_threshold" {
  description = "Redis memory threshold percentage"
  type        = number
  default     = 85
}

variable "enable_ecs_alarms" {
  description = "Enable ECS CloudWatch alarms"
  type        = bool
  default     = true
}

variable "ecs_monitoring_cpu_threshold" {
  description = "ECS CPU threshold percentage for alarms"
  type        = number
  default     = 85
}

variable "ecs_monitoring_memory_threshold" {
  description = "ECS memory threshold percentage for alarms"
  type        = number
  default     = 85
}

variable "enable_dashboard" {
  description = "Enable CloudWatch dashboard"
  type        = bool
  default     = true
}

# CloudTrail Variables
variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail for audit logging"
  type        = bool
  default     = true
}

variable "cloudtrail_multi_region" {
  description = "Enable multi-region CloudTrail"
  type        = bool
  default     = false # Dev can be single region
}

variable "enable_cloudtrail_cloudwatch" {
  description = "Enable CloudTrail integration with CloudWatch Logs"
  type        = bool
  default     = true
}

variable "cloudtrail_cloudwatch_retention_days" {
  description = "CloudWatch Logs retention period in days for CloudTrail"
  type        = number
  default     = 30 # Shorter retention for dev
}

variable "cloudtrail_log_retention_days" {
  description = "S3 log retention days before deletion"
  type        = number
  default     = 90 # Shorter retention for dev
}

variable "cloudtrail_log_transition_days" {
  description = "Days before transitioning logs to Glacier"
  type        = number
  default     = 30 # Faster transition for dev
}

# Observability Variables (Infrastructure only)
variable "observability_allowed_cidr" {
  description = "CIDR blocks allowed to access Prometheus and Grafana"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "prometheus_cpu" {
  description = "CPU units for Prometheus task"
  type        = string
  default     = "256"
}

variable "prometheus_memory" {
  description = "Memory in MB for Prometheus task"
  type        = string
  default     = "512"
}

variable "prometheus_desired_count" {
  description = "Desired number of Prometheus tasks"
  type        = number
  default     = 1
}

variable "grafana_cpu" {
  description = "CPU units for Grafana task"
  type        = string
  default     = "256"
}

variable "grafana_memory" {
  description = "Memory in MB for Grafana task"
  type        = string
  default     = "512"
}

variable "grafana_desired_count" {
  description = "Desired number of Grafana tasks"
  type        = number
  default     = 1
}

variable "observability_log_retention_days" {
  description = "CloudWatch log retention in days for observability services"
  type        = number
  default     = 7 # Shorter retention for dev
}

# CodeDeploy Variables
variable "codedeploy_config_name" {
  description = "CodeDeploy deployment configuration"
  type        = string
  default     = "CodeDeployDefault.AllAtOnce" # Faster for dev
}

variable "codedeploy_deployment_type" {
  description = "Deployment type: IN_PLACE or BLUE_GREEN"
  type        = string
  default     = "IN_PLACE"
}

variable "codedeploy_enable_traffic_control" {
  description = "Enable traffic control during deployment"
  type        = bool
  default     = true
}

variable "codedeploy_enable_auto_rollback" {
  description = "Enable automatic rollback on deployment failure"
  type        = bool
  default     = true
}

variable "codedeploy_enable_notifications" {
  description = "Enable SNS notifications for deployments"
  type        = bool
  default     = false # Disabled for dev
}

variable "codedeploy_notification_emails" {
  description = "Email addresses for deployment notifications"
  type        = list(string)
  default     = []
}

variable "codedeploy_create_bucket" {
  description = "Create S3 bucket for deployment artifacts"
  type        = bool
  default     = false
}
