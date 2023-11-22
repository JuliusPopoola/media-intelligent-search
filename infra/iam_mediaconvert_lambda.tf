resource "aws_iam_role" "mediaconvert_lambda_role" {
  name = "${var.mediaconvert_label}-lambda-role"
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

resource "aws_iam_policy" "mediaconvert_lambda_policy" {
  name = "${var.mediaconvert_label}-lambda-policy"
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
          "arn:aws:s3:::${var.instream_bucket_name}/*",
          "arn:aws:s3:::${var.outstream_bucket_name}/*"
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
          "arn:aws:s3:::${var.instream_bucket_name}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutBucketNotification"
        ]
        Resource = [
          "arn:aws:s3:::${var.outstream_bucket_name}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "mediaconvert:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mediaconvert_lambda_policy_basic_execution" {
  role       = aws_iam_role.mediaconvert_lambda_role.id
  policy_arn = aws_iam_policy.mediaconvert_lambda_policy.arn
}

resource "aws_iam_role" "mediaconvert" {
  name = "${var.mediaconvert_label}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "mediaconvert.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "mediaconvert" {
  name = "${var.mediaconvert_label}-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "execute-api:Invoke",
          "execute-api:ManageConnections"
        ]
        Resource = "arn:aws:execute-api:*:*:*"
      },
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

resource "aws_iam_role_policy_attachment" "mediaconvert_job_policy_basic_execution" {
  role       = aws_iam_role.mediaconvert.id
  policy_arn = aws_iam_policy.mediaconvert.arn
}