variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "codedeploy_service_role_arn" {
  description = "ARN of IAM role for CodeDeploy service"
  type        = string
}

variable "autoscaling_groups" {
  description = "List of Auto Scaling Group names"
  type        = list(string)
  default     = []
}

variable "target_group_name" {
  description = "ALB target group name for deployment"
  type        = string
}

variable "deployment_config_name" {
  description = "CodeDeploy deployment configuration name"
  type        = string
  default     = "CodeDeployDefault.OneAtATime"
}

variable "deployment_type" {
  description = "Deployment type: IN_PLACE or BLUE_GREEN"
  type        = string
  default     = "IN_PLACE"
}

variable "enable_traffic_control" {
  description = "Enable traffic control during deployment"
  type        = bool
  default     = true
}

variable "enable_auto_rollback" {
  description = "Enable automatic rollback on deployment failure"
  type        = bool
  default     = true
}

variable "auto_rollback_events" {
  description = "Events that trigger auto rollback"
  type        = list(string)
  default     = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
}

variable "enable_alarm_monitoring" {
  description = "Enable CloudWatch alarm monitoring for deployments"
  type        = bool
  default     = false
}

variable "alarm_names" {
  description = "List of CloudWatch alarm names to monitor"
  type        = list(string)
  default     = []
}

variable "ignore_poll_alarm_failure" {
  description = "Ignore failures when polling alarm status"
  type        = bool
  default     = false
}

variable "blue_green_terminate_action" {
  description = "Action for blue instances after deployment"
  type        = string
  default     = "TERMINATE"
}

variable "blue_green_termination_wait_time" {
  description = "Wait time before terminating blue instances (minutes)"
  type        = number
  default     = 5
}

variable "deployment_ready_timeout_action" {
  description = "Action when deployment ready timeout occurs"
  type        = string
  default     = "CONTINUE_DEPLOYMENT"
}

variable "deployment_ready_wait_time" {
  description = "Wait time for deployment ready (minutes)"
  type        = number
  default     = 0
}

variable "green_fleet_provisioning_action" {
  description = "How green fleet is provisioned"
  type        = string
  default     = "COPY_AUTO_SCALING_GROUP"
}

variable "ec2_tag_filters" {
  description = "EC2 tag filters for deployment targets"
  type = list(object({
    key   = string
    type  = string
    value = string
  }))
  default = []
}

variable "outdated_instances_strategy" {
  description = "Strategy for handling outdated instances"
  type        = string
  default     = "UPDATE"
}

variable "enable_deployment_notifications" {
  description = "Enable SNS notifications for deployments"
  type        = bool
  default     = true
}

variable "notification_endpoints" {
  description = "Email addresses for deployment notifications"
  type        = list(string)
  default     = []
}

variable "enable_sns_encryption" {
  description = "Enable encryption for SNS topic"
  type        = bool
  default     = true
}

variable "trigger_events" {
  description = "Deployment events that trigger SNS notifications"
  type        = list(string)
  default = [
    "DeploymentStart",
    "DeploymentSuccess",
    "DeploymentFailure",
    "DeploymentStop",
    "DeploymentRollback"
  ]
}

variable "enable_deployment_failure_alarm" {
  description = "Enable CloudWatch alarm for deployment failures"
  type        = bool
  default     = true
}

variable "create_deployment_bucket" {
  description = "Create S3 bucket for deployment artifacts"
  type        = bool
  default     = false
}

variable "deployment_artifact_retention_days" {
  description = "Days to retain deployment artifacts in S3"
  type        = number
  default     = 30
}

variable "deployment_artifact_noncurrent_version_retention_days" {
  description = "Days to retain noncurrent versions"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
