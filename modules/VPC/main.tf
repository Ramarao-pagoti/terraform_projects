resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = "phoenix-${var.environment}-vpc"
    }
  )
}

resource "aws_subnet" "public" {
    for_each = local.public_subnets
    vpc_id            = aws_vpc.this.id
    cidr_block        = each.value.cidr
    availability_zone = each.value.az
    map_public_ip_on_launch = true
    tags = merge(
      local.common_tags,
      {
        Name = each.key
        "kubernetes.io/role/elb" = "1"
      }
    )
  
}

resource "aws_subnet" "private_app" {
    for_each = local.private_app_subnets
    vpc_id            = aws_vpc.this.id
    cidr_block        = each.value.cidr
    availability_zone = each.value.az
    tags = merge(
      local.common_tags,
      {
        Name = each.key

      "kubernetes.io/role/elb" = "1"
    }
    )
    
  }

