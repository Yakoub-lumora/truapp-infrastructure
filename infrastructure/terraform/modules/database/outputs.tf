# Cluster Outputs
output "cluster_id" {
  description = "Aurora cluster ID"
  value       = aws_rds_cluster.main.id
}

output "cluster_arn" {
  description = "Aurora cluster ARN"
  value       = aws_rds_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Aurora cluster writer endpoint"
  value       = aws_rds_cluster.main.endpoint
}

output "cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = aws_rds_cluster.main.reader_endpoint
}

output "cluster_port" {
  description = "Aurora cluster port"
  value       = aws_rds_cluster.main.port
}

output "cluster_database_name" {
  description = "Name of the default database"
  value       = aws_rds_cluster.main.database_name
}

output "cluster_master_username" {
  description = "Master username for the database"
  value       = aws_rds_cluster.main.master_username
  sensitive   = true
}

output "cluster_resource_id" {
  description = "Cluster resource ID"
  value       = aws_rds_cluster.main.cluster_resource_id
}

# Instance Outputs
output "writer_instance_id" {
  description = "Writer instance ID"
  value       = aws_rds_cluster_instance.writer.id
}

output "writer_instance_endpoint" {
  description = "Writer instance endpoint"
  value       = aws_rds_cluster_instance.writer.endpoint
}

output "reader_instance_ids" {
  description = "Reader instance IDs"
  value       = aws_rds_cluster_instance.reader[*].id
}

output "reader_instance_endpoints" {
  description = "Reader instance endpoints"
  value       = aws_rds_cluster_instance.reader[*].endpoint
}

# Subnet Group Output
output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_arn" {
  description = "DB subnet group ARN"
  value       = aws_db_subnet_group.main.arn
}

# Connection String Output
output "connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = "postgresql://${aws_rds_cluster.main.master_username}@${aws_rds_cluster.main.endpoint}:${aws_rds_cluster.main.port}/${aws_rds_cluster.main.database_name}"
  sensitive   = true
}

# ElastiCache Redis Outputs
output "redis_replication_group_id" {
  description = "Redis replication group ID"
  value       = aws_elasticache_replication_group.main.id
}

output "redis_primary_endpoint" {
  description = "Redis primary endpoint address"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Redis reader endpoint address"
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "redis_port" {
  description = "Redis port"
  value       = aws_elasticache_replication_group.main.port
}

output "redis_connection_string" {
  description = "Redis connection string"
  value       = "redis://${aws_elasticache_replication_group.main.primary_endpoint_address}:${aws_elasticache_replication_group.main.port}"
  sensitive   = true
}
