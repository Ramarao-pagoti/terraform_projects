locals {
  common_tags = {
    Project     = "ecommerce-platform"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb" "this" {
  name               = "ecommerce-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "ecommerce-${var.environment}-alb"
    }
  )
  
}

resource "aws_alb_target_group" "ecs" {
    name     = "ecommerce-${var.environment}-tg"
    port     = 8080
    protocol = "HTTP"
    target_type = "ip"
    vpc_id   = var.vpc_id
    health_check {
      enabled = true
      path = "/" 
      protocol = "HTTP"
      matcher = "200"
      interval = 30
      timeout = 5
      healthy_threshold = 2
      unhealthy_threshold = 2
    }
    
    tags = merge(
        local.common_tags,
        {
        Name = "ecommerce-${var.environment}-tg"
        }
    )
  
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.this.arn
    port              = 80
    protocol          = "HTTP"
    default_action {
      type             = "forward"
      target_group_arn = aws_alb_target_group.ecs.arn
    }
}