# ALB Security Group
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "alb_security_group_name" {
  description = "Name of the ALB security group"
  value       = aws_security_group.alb.name
}

# EC2 App Security Group
output "ec2_app_security_group_id" {
  description = "ID of the EC2 app security group"
  value       = aws_security_group.ec2_app.id
}

output "ec2_app_security_group_name" {
  description = "Name of the EC2 app security group"
  value       = aws_security_group.ec2_app.name
}

# Bastion Security Group
output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.bastion.id
}

output "bastion_security_group_name" {
  description = "Name of the bastion security group"
  value       = aws_security_group.bastion.name
}

# ECS Workers Security Group
output "ecs_workers_security_group_id" {
  description = "ID of the ECS workers security group"
  value       = aws_security_group.ecs_workers.id
}

output "ecs_workers_security_group_name" {
  description = "Name of the ECS workers security group"
  value       = aws_security_group.ecs_workers.name
}

# RDS Security Group
output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "rds_security_group_name" {
  description = "Name of the RDS security group"
  value       = aws_security_group.rds.name
}

# ElastiCache Security Group
output "elasticache_security_group_id" {
  description = "ID of the ElastiCache security group"
  value       = aws_security_group.elasticache.id
}

output "elasticache_security_group_name" {
  description = "Name of the ElastiCache security group"
  value       = aws_security_group.elasticache.name
}

# EC2 IAM Role
output "ec2_iam_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2_app.arn
}

output "ec2_iam_role_name" {
  description = "Name of the EC2 IAM role"
  value       = aws_iam_role.ec2_app.name
}

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_app.arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_app.name
}

# ECS IAM Roles
output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_role_name" {
  description = "Name of the ECS task role"
  value       = aws_iam_role.ecs_task.name
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.name
}

# CloudTrail CloudWatch Logs Role
output "cloudtrail_cloudwatch_role_arn" {
  description = "ARN of CloudTrail CloudWatch Logs role"
  value       = var.enable_cloudtrail_cloudwatch ? aws_iam_role.cloudtrail_cloudwatch[0].arn : null
}

output "cloudtrail_cloudwatch_role_name" {
  description = "Name of CloudTrail CloudWatch Logs role"
  value       = var.enable_cloudtrail_cloudwatch ? aws_iam_role.cloudtrail_cloudwatch[0].name : null
}

# CodeDeploy Service Role
output "codedeploy_service_role_arn" {
  description = "ARN of CodeDeploy service role"
  value       = aws_iam_role.codedeploy.arn
}

output "codedeploy_service_role_name" {
  description = "Name of CodeDeploy service role"
  value       = aws_iam_role.codedeploy.name
}
