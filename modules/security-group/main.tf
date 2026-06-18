resource "aws_security_group" "alb" {
    name        = "ecommerce-${var.environment}-alb-sg"
    description = "Security group for ALB"
    vpc_id      = var.vpc_id
    
    ingress {
        description      = "Allow HTTP traffic from anywhere"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
  
}

ingress {
        description      = "Allow HTTPS traffic from anywhere"
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
  
}

    egress {
        description      = "Allow all outbound traffic"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
  
}

    tags = merge(
        local.common_tags,
        {
            Name = "ecommerce-${var.environment}-alb-sg"
        }
    )
}
resource "aws_security_group" "ecs" {
    name        = "ecommerce-${var.environment}-ecs-sg"
    description = "Security group for ECS"
    vpc_id      = var.vpc_id
    
    ingress {
        description      = "Allow SSH traffic from anywhere"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
  
}

    egress {
        description      = "Allow all outbound traffic"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
  
}

    tags = merge(
        local.common_tags,
        {
            Name = "ecommerce-${var.environment}-ecs-sg"
        }
    )
}
resource "aws_security_group" "rds" {
    name        = "ecommerce-${var.environment}-rds-sg"
    description = "Security group for RDS"
    vpc_id      = var.vpc_id

    ingress {
        description      = "Allow MySQL traffic from ECS security group"
        from_port        = 5432
        to_port          = 5432
        protocol         = "tcp"    
        security_groups  = [aws_security_group.ecs.id]
  
}

    egress {
        description      = "Allow all outbound traffic"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    tags = merge(
        local.common_tags,
        {
            Name = "ecommerce-${var.environment}-rds-sg"
        }
    )
}
resource "aws_security_group" "redis" {
    name        = "ecommerce-${var.environment}-redis-sg"
    description = "Security group for Redis"
    vpc_id      = var.vpc_id
    
    ingress {
        description      = "Allow Redis traffic from ECS security group"
        from_port        = 6379
        to_port          = 6379
        protocol         = "tcp"    
        security_groups  = [aws_security_group.ecs.id]
  
}

    egress {
        description      = "Allow all outbound traffic"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
  
}

    tags = merge(
        local.common_tags,
        {
            Name = "ecommerce-${var.environment}-redis-sg"
        }
    )
}