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
  bucket = aws_s3_bucket.transcribe_bucket.id
  acl    = "private"
}