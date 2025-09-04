variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH into bastion"
  type        = list(string)
  default     = []
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN for IAM policies"
  type        = string
  default     = ""
}

variable "enable_cloudtrail_cloudwatch" {
  description = "Enable CloudTrail CloudWatch Logs role"
  type        = bool
  default     = false
}

variable "cloudtrail_log_group_arn" {
  description = "CloudWatch Log Group ARN for CloudTrail (optional)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
