resource "aws_subnet" "public" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(cidrsubnet(aws_vpc.main.cidr_block, var.public_subnet_tier_newbits, var.public_subnet_tier_netnum), var.public_subnet_newbits, count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name"        = "${var.vpc_name}-public-${data.aws_availability_zones.available.names[count.index]}"
    "Environment" = var.environment
  }
}

resource "aws_route_table" "public" {
  count  = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.main.id
  tags = {
    "Name"        = "${var.vpc_name}-public-${data.aws_availability_zones.available.names[count.index]}"
    "Environment" = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

// Internet Gateway
resource "aws_internet_gateway" "internet" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name"        = "${var.vpc_name}-igw"
    "Environment" = var.environment
  }
}

resource "aws_route" "internet" {
  count                  = length(data.aws_availability_zones.available.names)
  route_table_id         = element(aws_route_table.public.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet.id
}
