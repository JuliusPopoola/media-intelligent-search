resource "aws_iam_role" "s3_lambda_iam" {
  name = var.s3_lambda_role_name
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

resource "aws_iam_policy" "s3_lambda_iam_policy" {
  name = var.s3_lambda_iam_policy
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

resource "aws_iam_role_policy_attachment" "terraform_lambda_iam_policy_basic_execution" {
  role       = aws_iam_role.s3_lambda_iam.id
  policy_arn = aws_iam_policy.s3_lambda_iam_policy.arn
}

resource "aws_iam_role" "mediaconvert_job" {
  name = "media-intelligent-role"
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

resource "aws_iam_policy" "mediaconvert_job" {
  name = "media-intelligent-role-policy"
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
  role       = aws_iam_role.mediaconvert_job.id
  policy_arn = aws_iam_policy.mediaconvert_job.arn
}