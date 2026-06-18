resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = "ecommerce-${var.environment}-vpc"
    }
  )
}

resource "aws_subnet" "public" {
    for_each = local.public_subnets
    vpc_id            = aws_vpc.this.id
    cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value.subnet_num)
    availability_zone = each.value.az
    map_public_ip_on_launch = true
    tags = merge(
      local.common_tags,
      {
        Name = "${var.environment}-${each.key}"
        Tier = "public"
      }
    )
  
}

resource "aws_subnet" "private_app" {
    for_each = local.private_app_subnets
    vpc_id            = aws_vpc.this.id
    cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value.subnet_num)
    availability_zone = each.value.az
    tags = merge(
      local.common_tags,
      {
        Name = "${var.environment}-${each.key}"
        Tier = "app"
      }
    )
  
}

resource "aws_subnet" "private_db" {
    for_each = local.private_db_subnets
    vpc_id            = aws_vpc.this.id
    cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value.subnet_num)
    availability_zone = each.value.az
    tags = merge(
      local.common_tags,
      {
        Name = "${var.environment}-${each.key}"
        Tier = "database"
      }
    )
  
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "ecommerce-${var.environment}-igw"
    }
  )
}