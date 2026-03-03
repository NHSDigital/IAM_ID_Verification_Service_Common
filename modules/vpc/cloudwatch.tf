resource "aws_cloudwatch_log_group" "vpc_flowlogs" {
  name = "/aws/vpc/${var.vpc_name}_flowlogs"
  tags = {
    "Name"        = "${var.vpc_name}-flowlogs"
    "Environment" = var.environment
  }
}
