resource "aws_iam_role" "kendra_source_lambda_role" {
  name = "${var.kendra_label}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "kendra_source_lambda_policy" {
  name = "${var.kendra_label}-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.transcribe_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketNotification"
        ]
        Resource = [
          "arn:aws:s3:::${var.transcribe_bucket_name}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kendra:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kendra_source_lambda_policy_basic_execution" {
  role       = aws_iam_role.kendra_source_lambda_role.id
  policy_arn = aws_iam_policy.kendra_source_lambda_policy.arn
}

