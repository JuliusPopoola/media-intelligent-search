resource "aws_s3_bucket" "transcribe_bucket" {
  bucket = var.transcribe_bucket_name
  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "transcribe_bucket" {
  bucket = aws_s3_bucket.transcribe_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "transcribe_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.transcribe_bucket]
  bucket     = aws_s3_bucket.transcribe_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_notification" "transcribe-lambda-trigger" {
  bucket = aws_s3_bucket.transcribe_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.kendra_source_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.transcribe_lambda_permission]
}

resource "aws_lambda_permission" "transcribe_lambda_permission" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.kendra_source_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.transcribe_bucket.arn
}