output "application_name" {
  description = "Name of the CodeDeploy application"
  value       = aws_codedeploy_app.main.name
}

output "application_id" {
  description = "ID of the CodeDeploy application"
  value       = aws_codedeploy_app.main.id
}

output "deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.main.deployment_group_name
}

output "deployment_group_id" {
  description = "ID of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.main.id
}

output "deployment_group_arn" {
  description = "ARN of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.main.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for deployment notifications"
  value       = var.enable_deployment_notifications ? aws_sns_topic.deployments[0].arn : null
}

output "sns_topic_name" {
  description = "Name of the SNS topic for deployment notifications"
  value       = var.enable_deployment_notifications ? aws_sns_topic.deployments[0].name : null
}

output "deployment_bucket_id" {
  description = "ID of the S3 bucket for deployment artifacts"
  value       = var.create_deployment_bucket ? aws_s3_bucket.deployments[0].id : null
}

output "deployment_bucket_arn" {
  description = "ARN of the S3 bucket for deployment artifacts"
  value       = var.create_deployment_bucket ? aws_s3_bucket.deployments[0].arn : null
}

output "deployment_failure_alarm_arn" {
  description = "ARN of the deployment failure CloudWatch alarm"
  value       = var.enable_deployment_failure_alarm ? aws_cloudwatch_metric_alarm.deployment_failures[0].arn : null
}
