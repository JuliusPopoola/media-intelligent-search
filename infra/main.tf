data "archive_file" "s3_lambda" {
  source_dir  = "../src/"
  output_path = "../src.zip"
  type        = "zip"
}

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
        Action = [
          "s3:*",
          "ses:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_lambda_iam_policy_basic_execution" {
  role       = aws_iam_role.s3_lambda_iam.id
  policy_arn = aws_iam_policy.s3_lambda_iam_policy.arn
}

resource "aws_lambda_function" "s3_lambda" {
  function_name    = var.s3_lambda_name
  role             = aws_iam_role.s3_lambda_iam.arn
  handler          = "${var.s3_lambda_handler_name}.lambda_handler"
  runtime          = var.runtime
  timeout          = var.timeout
  filename         = "../src.zip"
  source_code_hash = data.archive_file.s3_lambda.output_base64sha256
  environment {
    variables = {
      env            = var.environment
      SENDER_EMAIL   = var.sender_email
      RECEIVER_EMAIL = var.receiver_email
    }
  }
}

resource "aws_s3_bucket" "instream_bucket" {
  bucket = var.instream_bucket_name
  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "instream_bucket" {
  bucket = aws_s3_bucket.instream_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "instream_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.instream_bucket]
  bucket     = aws_s3_bucket.instream_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_notification" "instream-lambda-trigger" {
  bucket = aws_s3_bucket.instream_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
  depends_on = [aws_lambda_permission.s3_lambda_permission]
}

resource "aws_lambda_permission" "s3_lambda_permission" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.instream_bucket.arn
}