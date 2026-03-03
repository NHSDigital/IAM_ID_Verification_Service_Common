resource "aws_subnet" "private" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(cidrsubnet(aws_vpc.main.cidr_block, var.private_subnet_tier_newbits, var.private_subnet_tier_netnum), var.private_subnet_newbits, count.index)
  depends_on        = [aws_subnet.public]
  tags = {
    "Name"        = "${var.vpc_name}-private-${data.aws_availability_zones.available.names[count.index]}"
    "Environment" = var.environment
  }
}

resource "aws_route_table" "private" {
  count  = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.main.id
  tags = {
    "Name"        = "${var.vpc_name}-private-${data.aws_availability_zones.available.names[count.index]}"
    "Environment" = var.environment
  }
}

resource "aws_route_table_association" "private" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

// NAT Gateway
resource "aws_eip" "nat" {
  count = var.deploy_natgw == true ? length(data.aws_availability_zones.available.names) : 0
  tags = {
    "Name"        = "${var.vpc_name}-natgw-eip-${data.aws_availability_zones.available.names[count.index]}"
    "Environment" = var.environment
  }
}

resource "aws_nat_gateway" "nat" {
  count         = var.deploy_natgw == true ? length(data.aws_availability_zones.available.names) : 0
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  tags = {
    "Name"        = "${var.vpc_name}-natgw-${data.aws_availability_zones.available.names[count.index]}"
    "Environment" = var.environment
  }
}

resource "aws_route" "nat" {
  count                  = var.deploy_natgw == true ? length(data.aws_availability_zones.available.names) : 0
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
}
