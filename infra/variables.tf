variable "s3_lambda_role_name" {
  default     = ""
  description = "Name of the role for the Lambda that receives S3 trigger"
}

variable "s3_lambda_iam_policy" {
  default     = ""
  description = "Name of the policy for the Lambda that receives S3 trigger"
}

variable "s3_lambda_name" {
  default     = ""
  description = "Name of the Lambda that receives S3 trigger"
}

variable "s3_lambda_handler_name" {
  default     = ""
  description = "Name of the Lambda handler that receives S3 trigger"
}

variable "runtime" {
  default     = ""
  description = "The Lambda handler runtime"
}

variable "timeout" {
  default     = ""
  description = "The Lambda handler timeout"
}

variable "environment" {
  default     = "dev"
  description = "The environment"
}

variable "sender_email" {
  default = ""
}

variable "receiver_email" {
  default = ""
}

variable "instream_bucket_name" {
  default     = ""
  description = "The name of the bucket for input video stream"
}