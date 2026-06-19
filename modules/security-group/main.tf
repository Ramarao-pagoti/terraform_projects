resource "aws_security_group" "alb" {
   name = "alb-sg"
   description = "Security group for ALB"
    vpc_id = var.vpc_id
   tags = {
     Name = "alb-sg"
   }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
    security_group_id = aws_security_group.alb.id
    from_port = 443
    to_port = 443
    ip_protocol ="tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_egress" {
    security_group_id = aws_security_group.alb.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}

resource "aws_security_group" "eks_nodes" {
  name = "eks-nodes-sg"
  description = "EKS Worker Nodes"
  vpc_id = var.vpc_id
  tags = {
    Name = "eks-nodes-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_to_eks" {
  security_group_id = aws_security_group.eks_nodes.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "eks_egress" {
  security_group_id = aws_security_group.eks_nodes.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_security_group" "rds" {
    name = "rds-sg"
    description = "RDS"
    vpc_id = var.vpc_id
    tags = {
        Name = "rds-sg"
    }
  
}

resource "aws_vpc_security_group_ingress_rule" "eks_to_rds" {
   security_group_id = aws_security_group.rds.id
   referenced_security_group_id = aws_security_group.eks_nodes.id
   from_port = 5432
   to_port = 5432
   ip_protocol = "tcp"
}

resource "aws_security_group" "redis" {
  name = "redis-sg"
  description = "Redis"
  vpc_id = var.vpc_id
  tags = {
    Name = "redis-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_to_redis" {

  security_group_id = aws_security_group.redis.id
  referenced_security_group_id = aws_security_group.eks_nodes.id

  from_port = 6379
  to_port   = 6379

  ip_protocol = "tcp"
}

resource "aws_security_group" "efs" {
  name = "efs-sg"
  description = "EFS"
  vpc_id = var.vpc_id
  tags = {
    Name = "efs-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_to_efs" {
    security_group_id = aws_security_group.efs.id
    referenced_security_group_id = aws_security_group.eks_nodes.id
    from_port = 2049
    to_port = 2049
    ip_protocol = "tcp"
}