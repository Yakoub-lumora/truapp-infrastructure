# Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-${var.environment}-app-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    arn = var.iam_instance_profile_arn
  }

  vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    project_name = var.project_name
    environment  = var.environment
    region       = var.aws_region
  }))

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name        = "${var.project_name}-${var.environment}-app"
        Environment = var.environment
        Project     = var.project_name
      },
      var.tags
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      {
        Name        = "${var.project_name}-${var.environment}-app-volume"
        Environment = var.environment
        Project     = var.project_name
      },
      var.tags
    )
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-launch-template"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name_prefix        = "tru-"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_group_ids
  subnets            = var.public_subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-alb"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# Target Group
resource "aws_lb_target_group" "app" {
  name_prefix = "tru-"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/api/health"
    protocol            = "HTTP"
    matcher             = "200"
  }

  deregistration_delay = 30

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-tg"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# HTTP Listener (redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-http-listener"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  count             = var.acm_certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-https-listener"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name_prefix               = "${var.project_name}-${var.environment}-asg-"
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Policy - CPU Based
resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "${var.project_name}-${var.environment}-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_value
  }
}

# Auto Scaling Policy - Memory Based (CloudWatch Custom Metric)
resource "aws_autoscaling_policy" "memory_policy" {
  count                  = var.enable_memory_scaling ? 1 : 0
  name                   = "${var.project_name}-${var.environment}-memory-policy"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = var.memory_target_value
    customized_metric_specification {
      metrics {
        id    = "m1"
        label = "Get the memory utilization"
        metric_stat {
          metric {
            namespace   = "CWAgent"
            metric_name = "mem_used_percent"
            dimensions {
              name  = "AutoScalingGroupName"
              value = aws_autoscaling_group.app.name
            }
          }
          stat = "Average"
        }
      }
    }
  }
}
