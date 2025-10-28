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

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "observability_alb_arn" {
  description = "ARN of the load balancer for observability services"
  type        = string
}

variable "app_security_group_id" {
  description = "Security group ID of the app service for metrics scraping"
  type        = string
}

variable "worker_security_group_id" {
  description = "Security group ID of the worker service for metrics scraping"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of existing ECS task execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of existing ECS task role"
  type        = string
}

# ========================================
# Access Control
# ========================================

variable "observability_allowed_cidr" {
  description = "CIDR blocks allowed to access Prometheus and Grafana"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ========================================
# Prometheus Infrastructure
# ========================================

variable "prometheus_cpu" {
  description = "CPU units for Prometheus task"
  type        = string
  default     = "512"
}

variable "prometheus_memory" {
  description = "Memory in MB for Prometheus task"
  type        = string
  default     = "1024"
}

variable "prometheus_desired_count" {
  description = "Desired number of Prometheus tasks"
  type        = number
  default     = 1
}

# ========================================
# Grafana Infrastructure
# ========================================

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

# ========================================
# Logging Configuration
# ========================================

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

# ========================================
# Common Tags
# ========================================

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
