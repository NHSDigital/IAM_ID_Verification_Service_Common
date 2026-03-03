resource "aws_iam_role" "flowlog_cloudwatch_access" {
  name               = "${var.vpc_name}-flowlog-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.flowlog_cloudwatch_access_assume.json
  tags = {
    "Name"        = "${var.vpc_name}-flowlog-role"
    "Environment" = var.environment
  }
}

data "aws_iam_policy_document" "flowlog_cloudwatch_access_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "flowlog_cloudwatch_access_policy" {
  name        = "${var.vpc_name}-flowlog-policy"
  description = "VPC Flowlogs Cloudwatch Access Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": [
          "*"
      ]
    }
  ]
}
EOF

  tags = {
    "Name"        = "${var.vpc_name}-flowlog-policy"
    "Environment" = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "attach_flowlog_cloudwatch_access_policy" {
  role       = aws_iam_role.flowlog_cloudwatch_access.name
  policy_arn = aws_iam_policy.flowlog_cloudwatch_access_policy.arn
}
