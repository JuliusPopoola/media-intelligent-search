

variable "region" {
  default = ""
}

variable "account_id" {
  default     = ""
  description = "The account ID where the servies are being deployed"
}
variable "mediaconvert_label" {
  default     = ""
  description = "The label for the media converter"
}

variable "transcribe_label" {
  default     = ""
  description = "The label for transcribe"
}

variable "kendra_label" {
  default     = ""
  description = "The label for kendra"
}

variable "mediaconvert_lambda_handler_name" {
  default     = ""
  description = "Name of the Lambda handler that receives S3 trigger"
}

variable "transcribe_lambda_handler_name" {
  default     = ""
  description = "Name of the Lambda handler that receives S3 trigger to create a transcribe job"
}

variable "kendra_source_lambda_handler_name" {
  default     = ""
  description = "Name of the Lambda handler that receives S3 trigger to load documents into Kendra"
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

variable "outstream_bucket_name" {
  default     = ""
  description = "The name of the bucket for output video stream from Media Converter"
}

variable "transcribe_bucket_name" {
  default     = ""
  description = "The name of the bucket for transcribed output"
}

variable "mediaconvert_endpoint" {
  default     = ""
  description = "The media converter end point"
}