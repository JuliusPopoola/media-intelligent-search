resource "aws_iam_role" "transcribe_lambda_role" {
  name = "${var.transcribe_label}-lambda-role"
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

resource "aws_iam_policy" "transcribe_lambda_policy" {
  name = "${var.transcribe_label}-lambda-policy"
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
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.outstream_bucket_name}/*",
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
          "arn:aws:s3:::${var.outstream_bucket_name}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutBucketNotification"
        ]
        Resource = [
          "arn:aws:s3:::${var.transcribe_bucket_name}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "transcribe:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "transcribe_lambda_iam_policy_basic_execution" {
  role       = aws_iam_role.transcribe_lambda_role.id
  policy_arn = aws_iam_policy.transcribe_lambda_policy.arn
}

resource "aws_iam_role" "transcribe" {
  name = "${var.transcribe_label}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "transcribe.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "transcribe" {
  name = "${var.transcribe_label}-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "s3-object-lambda:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "transcribe_job_policy_basic_execution" {
  role       = aws_iam_role.transcribe.id
  policy_arn = aws_iam_policy.transcribe.arn
}