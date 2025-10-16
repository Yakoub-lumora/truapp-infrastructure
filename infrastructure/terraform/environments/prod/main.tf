terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  tags                 = var.tags
}


# Security Module
module "security" {
  source = "../../modules/security"

  project_name                 = var.project_name
  environment                  = var.environment
  vpc_id                       = module.networking.vpc_id
  allowed_ssh_cidr             = var.allowed_ssh_cidr
  s3_bucket_arn                = module.storage.s3_bucket_arn
  enable_cloudtrail_cloudwatch = var.enable_cloudtrail_cloudwatch
  cloudtrail_log_group_arn     = "" # Will be set by monitoring module output
  tags                         = var.tags
}

# Database Module
module "database" {
  source = "../../modules/database"

  project_name                    = var.project_name
  environment                     = var.environment
  vpc_id                          = module.networking.vpc_id
  private_subnet_ids              = module.networking.private_subnet_ids
  db_security_group_ids           = [module.security.rds_security_group_id]
  redis_security_group_ids        = [module.security.elasticache_security_group_id]
  database_name                   = var.database_name
  master_username                 = var.master_username
  master_password                 = var.master_password
  engine_version                  = var.engine_version
  instance_class                  = var.instance_class
  backup_retention_period         = var.backup_retention_period
  skip_final_snapshot             = var.skip_final_snapshot
  deletion_protection             = var.deletion_protection
  create_read_replica             = var.create_read_replica
  redis_node_type                 = var.redis_node_type
  redis_num_cache_nodes           = var.redis_num_cache_nodes
  enable_enhanced_monitoring      = var.enable_enhanced_monitoring
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  tags                            = var.tags
}

# Storage Module
module "storage" {
  source = "../../modules/storage"

  project_name                = var.project_name
  environment                 = var.environment
  bucket_name                 = var.bucket_name
  enable_versioning           = var.enable_s3_versioning
  enable_lifecycle_rules      = var.enable_s3_lifecycle_rules
  temp_files_expiration_days  = var.temp_files_expiration_days
  glacier_transition_days     = var.glacier_transition_days
  old_version_expiration_days = var.old_version_expiration_days
  allowed_origins             = var.allowed_origins
  cloudfront_price_class      = var.cloudfront_price_class
  cloudfront_aliases          = var.cloudfront_aliases
  acm_certificate_arn         = var.acm_certificate_arn
  waf_web_acl_arn             = var.waf_web_acl_arn
  enable_cloudfront_logging   = var.enable_cloudfront_logging
  cloudfront_logging_bucket   = var.cloudfront_logging_bucket
  tags                        = var.tags
}

# Compute Module - EC2
module "ec2" {
  source = "../../modules/compute/ec2"

  project_name               = var.project_name
  environment                = var.environment
  aws_region                 = var.aws_region
  vpc_id                     = module.networking.vpc_id
  public_subnet_ids          = module.networking.public_subnet_ids
  private_subnet_ids         = module.networking.private_subnet_ids
  security_group_ids         = [module.security.ec2_app_security_group_id]
  alb_security_group_ids     = [module.security.alb_security_group_id]
  iam_instance_profile_arn   = module.security.ec2_instance_profile_arn
  ami_id                     = var.ami_id
  instance_type              = var.instance_type
  key_name                   = var.key_name
  root_volume_size           = var.root_volume_size
  enable_detailed_monitoring = var.enable_detailed_monitoring
  asg_min_size               = var.asg_min_size
  asg_max_size               = var.asg_max_size
  asg_desired_capacity       = var.asg_desired_capacity
  cpu_target_value           = var.cpu_target_value
  memory_target_value        = var.memory_target_value
  enable_memory_scaling      = var.enable_memory_scaling
  acm_certificate_arn        = var.acm_certificate_arn
  enable_deletion_protection = var.enable_alb_deletion_protection
  tags                       = var.tags
}

# Compute Module - ECS Workers
module "ecs_workers" {
  source = "../../modules/compute/ecs"

  project_name                = var.project_name
  environment                 = var.environment
  aws_region                  = var.aws_region
  private_subnet_ids          = module.networking.private_subnet_ids
  security_group_ids          = [module.security.ecs_workers_security_group_id]
  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.security.ecs_task_role_arn
  task_cpu                    = var.ecs_task_cpu
  task_memory                 = var.ecs_task_memory
  desired_count               = var.ecs_desired_count
  min_capacity                = var.ecs_min_capacity
  max_capacity                = var.ecs_max_capacity
  worker_image_tag            = var.ecs_worker_image_tag
  enable_container_insights   = var.ecs_enable_container_insights
  enable_execute_command      = var.ecs_enable_execute_command
  cpu_target_value            = var.ecs_cpu_target_value
  memory_target_value         = var.ecs_memory_target_value
  enable_memory_scaling       = var.ecs_enable_memory_scaling
  log_retention_days          = var.ecs_log_retention_days
  tags                        = var.tags
}

# Monitoring Module
module "monitoring" {
  source = "../../modules/monitoring"

  project_name                  = var.project_name
  environment                   = var.environment
  aws_region                    = var.aws_region
  alarm_email_endpoints         = var.alarm_email_endpoints
  enable_sns_encryption         = var.enable_sns_encryption
  enable_alb_alarms             = var.enable_alb_alarms
  alb_arn_suffix                = module.ec2.alb_arn_suffix
  target_group_arn_suffix       = module.ec2.target_group_arn_suffix
  alb_response_time_threshold   = var.alb_response_time_threshold
  alb_5xx_threshold             = var.alb_5xx_threshold
  enable_ec2_alarms             = var.enable_ec2_alarms
  asg_name                      = module.ec2.asg_name
  ec2_cpu_threshold             = var.ec2_cpu_threshold
  enable_memory_alarm           = var.enable_memory_alarm
  ec2_memory_threshold          = var.ec2_memory_threshold
  enable_rds_alarms             = var.enable_rds_alarms
  rds_cluster_id                = module.database.cluster_id
  rds_cpu_threshold             = var.rds_cpu_threshold
  rds_connections_threshold     = var.rds_connections_threshold
  rds_freeable_memory_threshold = var.rds_freeable_memory_threshold
  enable_redis_alarms           = var.enable_redis_alarms
  redis_replication_group_id    = module.database.redis_replication_group_id
  redis_cpu_threshold           = var.redis_cpu_threshold
  redis_memory_threshold        = var.redis_memory_threshold
  enable_ecs_alarms             = var.enable_ecs_alarms
  ecs_cluster_name              = module.ecs_workers.ecs_cluster_name
  ecs_service_name              = module.ecs_workers.ecs_service_name
  ecs_cpu_threshold             = var.ecs_monitoring_cpu_threshold
  ecs_memory_threshold          = var.ecs_monitoring_memory_threshold
  enable_dashboard              = var.enable_dashboard

  # CloudTrail Configuration
  enable_cloudtrail                    = var.enable_cloudtrail
  cloudtrail_multi_region              = var.cloudtrail_multi_region
  enable_cloudtrail_cloudwatch         = var.enable_cloudtrail_cloudwatch
  cloudtrail_cloudwatch_retention_days = var.cloudtrail_cloudwatch_retention_days
  cloudtrail_log_retention_days        = var.cloudtrail_log_retention_days
  cloudtrail_log_transition_days       = var.cloudtrail_log_transition_days
  cloudtrail_cloudwatch_role_arn       = module.security.cloudtrail_cloudwatch_role_arn

  tags = var.tags
}

# CodeDeploy Module
module "codedeploy" {
  source = "../../modules/codedeploy"

  project_name                    = var.project_name
  environment                     = var.environment
  codedeploy_service_role_arn     = module.security.codedeploy_service_role_arn
  autoscaling_groups              = [module.ec2.asg_name]
  target_group_name               = module.ec2.target_group_name
  deployment_config_name          = var.codedeploy_config_name
  deployment_type                 = var.codedeploy_deployment_type
  enable_traffic_control          = var.codedeploy_enable_traffic_control
  enable_auto_rollback            = var.codedeploy_enable_auto_rollback
  enable_deployment_notifications = var.codedeploy_enable_notifications
  notification_endpoints          = var.codedeploy_notification_emails
  create_deployment_bucket        = var.codedeploy_create_bucket
  tags                            = var.tags
}