output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "nat_gateway_ips" {
  description = "NAT Gateway public IPs"
  value       = module.networking.nat_gateway_public_ips
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.security.alb_security_group_id
}

output "ec2_app_security_group_id" {
  description = "EC2 app security group ID"
  value       = module.security.ec2_app_security_group_id
}

output "bastion_security_group_id" {
  description = "Bastion security group ID"
  value       = module.security.bastion_security_group_id
}

output "ecs_workers_security_group_id" {
  description = "ECS workers security group ID"
  value       = module.security.ecs_workers_security_group_id
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = module.security.rds_security_group_id
}

output "elasticache_security_group_id" {
  description = "ElastiCache security group ID"
  value       = module.security.elasticache_security_group_id
}

# Database Outputs
output "rds_cluster_endpoint" {
  description = "RDS cluster endpoint"
  value       = module.database.cluster_endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "RDS cluster reader endpoint"
  value       = module.database.cluster_reader_endpoint
}

output "redis_primary_endpoint" {
  description = "Redis primary endpoint"
  value       = module.database.redis_primary_endpoint
}

output "redis_connection_string" {
  description = "Redis connection string"
  value       = module.database.redis_connection_string
  sensitive   = true
}

# Storage Outputs
output "s3_bucket_id" {
  description = "S3 bucket ID"
  value       = module.storage.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.storage.s3_bucket_arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.storage.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name"
  value       = module.storage.cloudfront_domain_name
}

output "cdn_url" {
  description = "CDN URL for accessing images"
  value       = module.storage.cdn_url
}

# Compute Outputs
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.ec2.alb_dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.ec2.alb_arn
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.ec2.asg_name
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = module.ec2.launch_template_id
}

# ECS Outputs
output "ecr_repository_url" {
  description = "ECR repository URL for workers"
  value       = module.ecs_workers.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs_workers.ecs_cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs_workers.ecs_service_name
}

output "ecs_log_group_name" {
  description = "CloudWatch log group name for ECS"
  value       = module.ecs_workers.log_group_name
}

# Monitoring Outputs
output "sns_topic_arn" {
  description = "SNS topic ARN for alarms"
  value       = module.monitoring.sns_topic_arn
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.monitoring.dashboard_name
}
