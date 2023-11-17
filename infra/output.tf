output "arn" {
  value = aws_lambda_function.s3_lambda.arn
}

output "mediaconvert_role_arn" {
  value = aws_iam_role.mediaconvert_job
}

output "lambda_role_arn" {
  value = aws_iam_role.s3_lambda_iam.arn
}
