resource "aws_vpc_endpoint" "s3_endpoint" {
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_id       = aws_vpc.main.id
  tags = {
    "Name"        = "${var.vpc_name}-s3-endpoint"
    "Environment" = var.environment
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3_endpoint_private_route_table" {
  count           = length(data.aws_availability_zones.available.names)
  route_table_id  = element(aws_route_table.private.*.id, count.index)
  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_endpoint_public_route_table" {
  count           = length(data.aws_availability_zones.available.names)
  route_table_id  = element(aws_route_table.public.*.id, count.index)
  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  vpc_id              = aws_vpc.main.id
  for_each            = var.vpc_endpoints
  service_name        = each.value
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.vpc_endpoint_sg.id,
  ]

  tags = {
    "Name"        = "${var.vpc_name}-${each.key}"
    "Environment" = var.environment
  }
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name   = "${var.vpc_name}-endpoint-sg"
  vpc_id = aws_vpc.main.id
  tags = {
    "Name"        = "${var.vpc_name}-endpoint-sg"
    "Environment" = var.environment
  }
}

resource "aws_security_group_rule" "vpc_endpoint_https_in" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [for subnet in aws_subnet.private : subnet.cidr_block]
  security_group_id = aws_security_group.vpc_endpoint_sg.id
}

resource "aws_security_group_rule" "vpc_endpoint_https_out" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpc_endpoint_sg.id
}
