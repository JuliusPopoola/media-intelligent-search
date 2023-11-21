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
    lambda_function_arn = aws_lambda_function.mediaconvert_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.instream_lambda_permission]
}

resource "aws_lambda_permission" "instream_lambda_permission" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mediaconvert_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.instream_bucket.arn
}