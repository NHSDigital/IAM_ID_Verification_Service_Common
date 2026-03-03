resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    "Name"        = var.vpc_name
    "Environment" = var.environment
  }
}

resource "aws_flow_log" "vpc_flow_log_common" {
  count                = var.enable_flow_logs ? 1 : 0
  log_destination      = aws_cloudwatch_log_group.vpc_flowlogs.arn
  log_destination_type = "cloud-watch-logs"
  iam_role_arn         = aws_iam_role.flowlog_cloudwatch_access.arn
  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  tags = {
    "Name"        = var.vpc_name
    "Environment" = var.environment
  }
}
