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

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of ECS task execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of ECS task role"
  type        = string
}

# ========================================
# ECS Configuration
# ========================================

variable "task_cpu" {
  description = "CPU units for ECS task (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "512"
}

variable "task_memory" {
  description = "Memory for ECS task in MB (512, 1024, 2048, 4096, 8192)"
  type        = string
  default     = "1024"
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 4
}

variable "worker_image_tag" {
  description = "Docker image tag for worker"
  type        = string
  default     = "latest"
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = false
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for debugging"
  type        = bool
  default     = false
}

# ========================================
# Auto Scaling Configuration
# ========================================

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto scaling"
  type        = number
  default     = 80
}

variable "enable_memory_scaling" {
  description = "Enable memory-based auto scaling"
  type        = bool
  default     = false
}

# ========================================
# Logging Configuration
# ========================================

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

# ========================================
# Tags
# ========================================

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
