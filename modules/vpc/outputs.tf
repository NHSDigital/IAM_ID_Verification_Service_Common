# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.main.arn
}

# Public Subnet Outputs
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_azs" {
  description = "List of availability zones of public subnets"
  value       = aws_subnet.public[*].availability_zone
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = aws_route_table.public[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.internet.id
}

# Private Subnet Outputs
output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_azs" {
  description = "List of availability zones of private subnets"
  value       = aws_subnet.private[*].availability_zone
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private[*].id
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs (empty if NAT gateways not deployed)"
  value       = aws_nat_gateway.nat[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public Elastic IP addresses associated with NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

# VPC Endpoint Outputs
output "s3_vpc_endpoint_id" {
  description = "The ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3_endpoint.id
}

output "interface_vpc_endpoint_ids" {
  description = "Map of interface VPC endpoint identifiers to their IDs"
  value       = { for k, v in aws_vpc_endpoint.vpc_endpoint : k => v.id }
}

output "interface_vpc_endpoint_dns_entries" {
  description = "Map of interface VPC endpoint identifiers to their DNS entries"
  value       = { for k, v in aws_vpc_endpoint.vpc_endpoint : k => v.dns_entry }
}

output "vpc_endpoint_security_group_id" {
  description = "The ID of the security group for VPC endpoints"
  value       = aws_security_group.vpc_endpoint_sg.id
}

# Flow Logs Outputs
output "flow_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC flow logs (empty if flow logs not enabled)"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.vpc_flowlogs.name : ""
}

output "flow_logs_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC flow logs (empty if flow logs not enabled)"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.vpc_flowlogs.arn : ""
}

# Availability Zones
output "availability_zones" {
  description = "List of availability zones used in the region"
  value       = data.aws_availability_zones.available.names
}

# Region
output "region" {
  description = "The AWS region where the VPC is deployed"
  value       = data.aws_region.current.name
}
