# ========================================
# ECR Outputs
# ========================================

output "ecr_repository_url" {
  description = "URL of ECR repository for workers"
  value       = aws_ecr_repository.workers.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of ECR repository"
  value       = aws_ecr_repository.workers.arn
}

output "ecr_repository_name" {
  description = "Name of ECR repository"
  value       = aws_ecr_repository.workers.name
}

# ========================================
# ECS Cluster Outputs
# ========================================

output "ecs_cluster_id" {
  description = "ID of ECS cluster"
  value       = aws_ecs_cluster.workers.id
}

output "ecs_cluster_arn" {
  description = "ARN of ECS cluster"
  value       = aws_ecs_cluster.workers.arn
}

output "ecs_cluster_name" {
  description = "Name of ECS cluster"
  value       = aws_ecs_cluster.workers.name
}

# ========================================
# ECS Service Outputs
# ========================================

output "ecs_service_id" {
  description = "ID of ECS service"
  value       = aws_ecs_service.workers.id
}

output "ecs_service_name" {
  description = "Name of ECS service"
  value       = aws_ecs_service.workers.name
}

output "ecs_service_cluster" {
  description = "Cluster name of ECS service"
  value       = aws_ecs_service.workers.cluster
}

# ========================================
# ECS Task Definition Outputs
# ========================================

output "task_definition_arn" {
  description = "ARN of ECS task definition"
  value       = aws_ecs_task_definition.workers.arn
}

output "task_definition_family" {
  description = "Family of ECS task definition"
  value       = aws_ecs_task_definition.workers.family
}

output "task_definition_revision" {
  description = "Revision of ECS task definition"
  value       = aws_ecs_task_definition.workers.revision
}

# ========================================
# CloudWatch Log Group Output
# ========================================

output "log_group_name" {
  description = "Name of CloudWatch log group"
  value       = aws_cloudwatch_log_group.workers.name
}

output "log_group_arn" {
  description = "ARN of CloudWatch log group"
  value       = aws_cloudwatch_log_group.workers.arn
}
