data "archive_file" "s3_lambda" {
  source_dir  = "../src/"
  output_path = "../src.zip"
  type        = "zip"
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
      env                   = var.environment
      SENDER_EMAIL          = var.sender_email
      RECEIVER_EMAIL        = var.receiver_email
      REGION                = var.region,
      OUTPUT_BUCKET         = "${aws_s3_bucket.outstream_bucket.arn}",
      MEDIACONVERT_ROLE_ARN = aws_iam_role.mediaconvert_job.arn,
      MEDIACONVERT_ENDPOINT = var.mediaconvert_endpoint,
    }
  }
}