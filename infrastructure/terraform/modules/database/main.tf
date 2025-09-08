# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-db-"
  description = "Database subnet group for ${var.project_name}-${var.environment}"
  subnet_ids  = var.private_subnet_ids

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-db-subnet-group"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name        = "${var.project_name}-${var.environment}-redis-subnet-group"
  description = "ElastiCache subnet group for ${var.project_name}-${var.environment}"
  subnet_ids  = var.private_subnet_ids

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-redis-subnet-group"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# Aurora Cluster Parameter Group
resource "aws_rds_cluster_parameter_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-cluster-"
  family      = "aurora-postgresql15"
  description = "Cluster parameter group for ${var.project_name}-${var.environment}"

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-cluster-params"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Aurora DB Parameter Group
resource "aws_db_parameter_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-db-"
  family      = "aurora-postgresql15"
  description = "DB parameter group for ${var.project_name}-${var.environment}"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-db-params"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Aurora PostgreSQL Cluster
resource "aws_rds_cluster" "main" {
  cluster_identifier     = "${var.project_name}-${var.environment}-aurora-cluster"
  engine                 = "aurora-postgresql"
  engine_version         = var.engine_version
  database_name          = var.database_name
  master_username        = var.master_username
  master_password        = var.master_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.db_security_group_ids

  # Backup settings
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  skip_final_snapshot          = var.skip_final_snapshot
  final_snapshot_identifier    = var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Parameter groups
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name

  # CloudWatch logs
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  # High availability
  storage_encrypted   = true
  deletion_protection = var.deletion_protection
  apply_immediately   = var.apply_immediately

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-aurora-cluster"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Database"
    },
    var.tags
  )

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
      master_password
    ]
  }
}

# Aurora Cluster Instance - Writer (Primary)
resource "aws_rds_cluster_instance" "writer" {
  identifier              = "${var.project_name}-${var.environment}-aurora-writer"
  cluster_identifier      = aws_rds_cluster.main.id
  instance_class          = var.instance_class
  engine                  = aws_rds_cluster.main.engine
  engine_version          = aws_rds_cluster.main.engine_version
  db_parameter_group_name = aws_db_parameter_group.main.name

  # Monitoring
  monitoring_interval = var.enable_enhanced_monitoring ? var.monitoring_interval : 0
  monitoring_role_arn = var.enable_enhanced_monitoring ? var.monitoring_role_arn : null

  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Maintenance
  auto_minor_version_upgrade = true
  apply_immediately          = var.apply_immediately

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-aurora-writer"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Database"
      Role        = "Writer"
    },
    var.tags
  )
}

# Aurora Cluster Instance - Reader (Replica)
resource "aws_rds_cluster_instance" "reader" {
  count = var.create_read_replica ? 1 : 0

  identifier              = "${var.project_name}-${var.environment}-aurora-reader-${count.index + 1}"
  cluster_identifier      = aws_rds_cluster.main.id
  instance_class          = var.instance_class
  engine                  = aws_rds_cluster.main.engine
  engine_version          = aws_rds_cluster.main.engine_version
  db_parameter_group_name = aws_db_parameter_group.main.name

  # Monitoring
  monitoring_interval = var.enable_enhanced_monitoring ? var.monitoring_interval : 0
  monitoring_role_arn = var.enable_enhanced_monitoring ? var.monitoring_role_arn : null

  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Maintenance
  auto_minor_version_upgrade = true
  apply_immediately          = var.apply_immediately

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-aurora-reader-${count.index + 1}"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Database"
      Role        = "Reader"
    },
    var.tags
  )
}

# ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "main" {
  name        = "${var.project_name}-${var.environment}-redis-params"
  family      = "redis7"
  description = "Redis parameter group for ${var.project_name}-${var.environment}"

  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }

  parameter {
    name  = "timeout"
    value = "300"
  }

  parameter {
    name  = "tcp-keepalive"
    value = "300"
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-redis-params"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# CloudWatch Log Groups for Redis
resource "aws_cloudwatch_log_group" "redis_slow_log" {
  name              = "/aws/elasticache/${var.project_name}-${var.environment}/slow-log"
  retention_in_days = 7

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-redis-slow-log"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "redis_engine_log" {
  name              = "/aws/elasticache/${var.project_name}-${var.environment}/engine-log"
  retention_in_days = 7

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-redis-engine-log"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# ElastiCache Replication Group (Multi-AZ)
resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${var.project_name}-${var.environment}-redis"
  description          = "Redis cluster for ${var.project_name}-${var.environment}"
  engine               = "redis"
  engine_version       = var.redis_version
  node_type            = var.redis_node_type
  port                 = var.redis_port
  parameter_group_name = aws_elasticache_parameter_group.main.name

  num_cache_clusters         = var.redis_num_cache_nodes
  automatic_failover_enabled = true
  multi_az_enabled           = true

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = var.redis_security_group_ids

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  snapshot_retention_limit   = 5
  snapshot_window            = "03:00-05:00"
  maintenance_window         = "sun:05:00-sun:07:00"
  auto_minor_version_upgrade = true

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_engine_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-redis-cluster"
      Environment = var.environment
      Project     = var.project_name
      Component   = "Cache"
    },
    var.tags
  )
}
