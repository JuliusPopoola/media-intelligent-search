data "archive_file" "lambda_source" {
  source_dir  = "../src/"
  output_path = "../src.zip"
  type        = "zip"
}

resource "aws_lambda_function" "mediaconvert_lambda" {
  function_name    = "${var.mediaconvert_label}-lambda-function"
  role             = aws_iam_role.mediaconvert_lambda_role.arn
  handler          = "${var.mediaconvert_lambda_handler_name}.lambda_handler"
  runtime          = var.runtime
  timeout          = var.timeout
  filename         = "../src.zip"
  source_code_hash = data.archive_file.lambda_source.output_base64sha256
  environment {
    variables = {
      env                   = var.environment
      REGION                = var.region,
      OUTPUT_BUCKET         = var.outstream_bucket_name,
      MEDIACONVERT_ROLE_ARN = aws_iam_role.mediaconvert_job.arn,
      MEDIACONVERT_ENDPOINT = var.mediaconvert_endpoint,
    }
  }
}

resource "aws_lambda_function" "transcribe_lambda" {
  function_name    = "${var.transcribe_label}-lambda-function"
  role             = aws_iam_role.transcribe_lambda_role.arn
  handler          = "${var.transcribe_lambda_handler_name}.lambda_handler"
  runtime          = var.runtime
  timeout          = var.timeout
  filename         = "../src.zip"
  source_code_hash = data.archive_file.lambda_source.output_base64sha256
  environment {
    variables = {
      env                      = var.environment
      REGION                   = var.region,
      TRANSCRIBE_ROLE_ARN      = aws_iam_role.transcribe.arn,
      TRANSCRIBE_OUTPUT_BUCKET = var.transcribe_bucket_name
    }
  }
}