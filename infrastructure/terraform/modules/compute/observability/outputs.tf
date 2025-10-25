# ========================================
# EFS Outputs
# ========================================

output "prometheus_efs_id" {
  description = "ID of Prometheus EFS"
  value       = aws_efs_file_system.prometheus.id
}

output "prometheus_efs_arn" {
  description = "ARN of Prometheus EFS"
  value       = aws_efs_file_system.prometheus.arn
}

# ========================================
# Security Group Outputs
# ========================================

output "observability_tasks_security_group_id" {
  description = "Security group ID for observability tasks"
  value       = aws_security_group.observability_tasks.id
}

output "observability_alb_security_group_id" {
  description = "Security group ID for observability ALB"
  value       = aws_security_group.observability_alb.id
}

output "efs_security_group_id" {
  description = "Security group ID for EFS"
  value       = aws_security_group.efs.id
}

# ========================================
# Prometheus Outputs
# ========================================

output "prometheus_task_definition_arn" {
  description = "ARN of Prometheus task definition"
  value       = aws_ecs_task_definition.prometheus.arn
}

output "prometheus_task_definition_family" {
  description = "Family of Prometheus task definition"
  value       = aws_ecs_task_definition.prometheus.family
}

output "prometheus_service_name" {
  description = "Name of Prometheus ECS service"
  value       = aws_ecs_service.prometheus.name
}

output "prometheus_service_id" {
  description = "ID of Prometheus ECS service"
  value       = aws_ecs_service.prometheus.id
}

output "prometheus_target_group_arn" {
  description = "ARN of Prometheus target group"
  value       = aws_lb_target_group.prometheus.arn
}

output "prometheus_log_group_name" {
  description = "CloudWatch log group name for Prometheus"
  value       = aws_cloudwatch_log_group.prometheus.name
}

output "prometheus_log_group_arn" {
  description = "CloudWatch log group ARN for Prometheus"
  value       = aws_cloudwatch_log_group.prometheus.arn
}

# ========================================
# Grafana Outputs
# ========================================

output "grafana_task_definition_arn" {
  description = "ARN of Grafana task definition"
  value       = aws_ecs_task_definition.grafana.arn
}

output "grafana_task_definition_family" {
  description = "Family of Grafana task definition"
  value       = aws_ecs_task_definition.grafana.family
}

output "grafana_service_name" {
  description = "Name of Grafana ECS service"
  value       = aws_ecs_service.grafana.name
}

output "grafana_service_id" {
  description = "ID of Grafana ECS service"
  value       = aws_ecs_service.grafana.id
}

output "grafana_target_group_arn" {
  description = "ARN of Grafana target group"
  value       = aws_lb_target_group.grafana.arn
}

output "grafana_log_group_name" {
  description = "CloudWatch log group name for Grafana"
  value       = aws_cloudwatch_log_group.grafana.name
}

output "grafana_log_group_arn" {
  description = "CloudWatch log group ARN for Grafana"
  value       = aws_cloudwatch_log_group.grafana.arn
}

