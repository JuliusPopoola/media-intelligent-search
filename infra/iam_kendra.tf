resource "aws_iam_role" "kendra" {
  name = "${var.kendra_label}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "kendra.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "kendra" {
  name = "${var.kendra_label}-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:DescribeLogGroups"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "logs:CreateLogGroup",
        Resource = [
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/kendra/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:DescribeLogStreams",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/kendra/*:log-stream:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kendra_iam_policy_basic_execution" {
  role       = aws_iam_role.kendra.id
  policy_arn = aws_iam_policy.kendra.arn
}

resource "aws_kendra_index" "kendra" {
  name        = "${var.kendra_label}-index"
  role_arn    = aws_iam_role.kendra.arn
  edition     = "DEVELOPER_EDITION"
  description = "Kendra index for the Media intelliigent search"
}