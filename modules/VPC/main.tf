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

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "ecommerce-${var.environment}-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["public-a"].id

  tags = merge(
    local.common_tags,
    {
      Name = "ecommerce-${var.environment}-nat"
    }
  )


depends_on = [aws_internet_gateway.this]

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  
  tags = merge(

    local.common_tags,
    {
      Name = "ecommerce-${var.environment}-public-rt"
    }
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.this.id
  
  tags = merge(
    local.common_tags,
    {
      Name = "ecommerce-${var.environment}-private-app-rt"
    }
  )
}

resource "aws_route" "private_app_internet" {
  route_table_id         = aws_route_table.private_app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}
resource "aws_route_table_association" "private_app" {
  for_each = aws_subnet.private_app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_app.id
}

resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.this.id
  
  tags = merge(
    local.common_tags,
    {
      Name = "ecommerce-${var.environment}-private-db-rt"
    }
  )
}

resource "aws_route" "private_db_internet" {
  route_table_id         = aws_route_table.private_db.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private_db" {
  for_each = aws_subnet.private_db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_db.id
}