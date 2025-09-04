# EC2 App Role Outputs
output "ec2_app_role_arn" {
  description = "ARN of EC2 app instance role"
  value       = aws_iam_role.ec2_app.arn
}

output "ec2_app_role_name" {
  description = "Name of EC2 app instance role"
  value       = aws_iam_role.ec2_app.name
}

output "ec2_app_instance_profile_arn" {
  description = "ARN of EC2 app instance profile"
  value       = aws_iam_instance_profile.ec2_app.arn
}

output "ec2_app_instance_profile_name" {
  description = "Name of EC2 app instance profile"
  value       = aws_iam_instance_profile.ec2_app.name
}

# Bastion Role Outputs
output "bastion_role_arn" {
  description = "ARN of bastion instance role"
  value       = aws_iam_role.bastion.arn
}

output "bastion_role_name" {
  description = "Name of bastion instance role"
  value       = aws_iam_role.bastion.name
}

output "bastion_instance_profile_arn" {
  description = "ARN of bastion instance profile"
  value       = aws_iam_instance_profile.bastion.arn
}

output "bastion_instance_profile_name" {
  description = "Name of bastion instance profile"
  value       = aws_iam_instance_profile.bastion.name
}

# ECS Task Execution Role Outputs
output "ecs_task_execution_role_arn" {
  description = "ARN of ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "Name of ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.name
}

# ECS Task Role Outputs
output "ecs_task_role_arn" {
  description = "ARN of ECS task role"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_role_name" {
  description = "Name of ECS task role"
  value       = aws_iam_role.ecs_task.name
}

# RDS Enhanced Monitoring Role Outputs
output "rds_enhanced_monitoring_role_arn" {
  description = "ARN of RDS enhanced monitoring role"
  value       = aws_iam_role.rds_enhanced_monitoring.arn
}

output "rds_enhanced_monitoring_role_name" {
  description = "Name of RDS enhanced monitoring role"
  value       = aws_iam_role.rds_enhanced_monitoring.name
}
