variable "project_name" {
  description = "Project name to be used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket for image storage"
  type        = string
  default     = "tru-app-images"
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "enable_lifecycle_rules" {
  description = "Enable S3 lifecycle rules for cost optimization"
  type        = bool
  default     = true
}

variable "temp_files_expiration_days" {
  description = "Number of days before temp files are automatically deleted"
  type        = number
  default     = 7
}

variable "glacier_transition_days" {
  description = "Number of days before old versions transition to Glacier"
  type        = number
  default     = 30
}

variable "old_version_expiration_days" {
  description = "Number of days before old versions are permanently deleted"
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
  description = "List of CNAMEs (alternate domain names) for CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate for custom domain (leave empty for default CloudFront certificate)"
  type        = string
  default     = ""
}

variable "waf_web_acl_arn" {
  description = "ARN of WAF Web ACL to associate with CloudFront (leave empty to skip)"
  type        = string
  default     = ""
}

variable "enable_cloudfront_logging" {
  description = "Enable CloudFront access logging"
  type        = bool
  default     = false
}

variable "cloudfront_logging_bucket" {
  description = "S3 bucket for CloudFront logs (required if enable_cloudfront_logging is true)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
