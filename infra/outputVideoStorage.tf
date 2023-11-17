resource "aws_s3_bucket" "outstream_bucket" {
  bucket = var.outstream_bucket_name
  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "outstream_bucket" {
  bucket = aws_s3_bucket.outstream_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "outstream_bucket" {
  bucket = aws_s3_bucket.outstream_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "outstream_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.outstream_bucket,
  aws_s3_bucket_public_access_block.outstream_bucket]
  bucket = aws_s3_bucket.outstream_bucket.id
  acl    = "public-read-write"
}

# resource "aws_s3_bucket_notification" "outstream-lambda-trigger" {
#   bucket = aws_s3_bucket.outstream_bucket.id
#   lambda_function {
#     lambda_function_arn = aws_lambda_function.s3_lambda.arn
#     events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
#   }
#   depends_on = [aws_lambda_permission.s3_lambda_permission]
# }

# resource "aws_lambda_permission" "s3_lambda_permission" {
#   statement_id  = "AllowExecutionFromS3Bucket"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.s3_lambda.arn
#   principal     = "s3.amazonaws.com"
#   source_arn    = aws_s3_bucket.instream_bucket.arn
# }