# ========================================
# SNS Topic Outputs
# ========================================

output "sns_topic_arn" {
  description = "ARN of SNS topic for alarms"
  value       = aws_sns_topic.alarms.arn
}

output "sns_topic_name" {
  description = "Name of SNS topic for alarms"
  value       = aws_sns_topic.alarms.name
}

# ========================================
# Dashboard Outputs
# ========================================

output "dashboard_arn" {
  description = "ARN of CloudWatch dashboard"
  value       = var.enable_dashboard ? aws_cloudwatch_dashboard.main[0].dashboard_arn : null
}

output "dashboard_name" {
  description = "Name of CloudWatch dashboard"
  value       = var.enable_dashboard ? aws_cloudwatch_dashboard.main[0].dashboard_name : null
}

# ========================================
# CloudTrail Outputs
# ========================================

output "cloudtrail_id" {
  description = "ID of the CloudTrail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].id : null
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].arn : null
}

output "cloudtrail_bucket_id" {
  description = "ID of the S3 bucket storing CloudTrail logs"
  value       = var.enable_cloudtrail ? aws_s3_bucket.cloudtrail[0].id : null
}

output "cloudtrail_bucket_arn" {
  description = "ARN of the S3 bucket storing CloudTrail logs"
  value       = var.enable_cloudtrail ? aws_s3_bucket.cloudtrail[0].arn : null
}

output "cloudtrail_log_group_arn" {
  description = "ARN of CloudWatch Log Group for CloudTrail"
  value       = var.enable_cloudtrail && var.enable_cloudtrail_cloudwatch ? aws_cloudwatch_log_group.cloudtrail[0].arn : null
}

output "cloudtrail_log_group_name" {
  description = "Name of CloudWatch Log Group for CloudTrail"
  value       = var.enable_cloudtrail && var.enable_cloudtrail_cloudwatch ? aws_cloudwatch_log_group.cloudtrail[0].name : null
}
