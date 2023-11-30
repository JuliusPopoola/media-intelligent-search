data "archive_file" "mediaconvert_source" {
  source_dir  = "../src/mediaconvert"
  output_path = "../mediaconvert.zip"
  type        = "zip"
}

resource "aws_lambda_function" "mediaconvert_lambda" {
  function_name    = "${var.mediaconvert_label}-lambda-function"
  role             = aws_iam_role.mediaconvert_lambda_role.arn
  handler          = "${var.mediaconvert_lambda_handler_name}.lambda_handler"
  runtime          = var.runtime
  timeout          = var.timeout
  filename         = "../mediaconvert.zip"
  source_code_hash = data.archive_file.mediaconvert_source.output_base64sha256
  environment {
    variables = {
      env                   = var.environment
      REGION                = var.region,
      OUTPUT_BUCKET         = var.outstream_bucket_name,
      MEDIACONVERT_ROLE_ARN = aws_iam_role.mediaconvert.arn,
      MEDIACONVERT_ENDPOINT = var.mediaconvert_endpoint,
    }
  }
}

data "archive_file" "transcribe_lambda_zip" {
  source_dir  = "../src/transcribe"
  output_path = "../transcribe.zip"
  type        = "zip"
}

resource "aws_lambda_function" "transcribe_lambda" {
  function_name    = "${var.transcribe_label}-lambda-function"
  role             = aws_iam_role.transcribe_lambda_role.arn
  handler          = "${var.transcribe_lambda_handler_name}.lambda_handler"
  runtime          = var.runtime
  timeout          = var.timeout
  filename         = "../transcribe.zip"
  source_code_hash = data.archive_file.transcribe_lambda_zip.output_base64sha256
  environment {
    variables = {
      env                      = var.environment
      REGION                   = var.region,
      TRANSCRIBE_ROLE_ARN      = aws_iam_role.transcribe.arn,
      TRANSCRIBE_OUTPUT_BUCKET = var.transcribe_bucket_name
    }
  }
}

data "archive_file" "kendra_lambda_zip" {
  source_dir  = "../src/kendra"
  output_path = "../kendra.zip"
  type        = "zip"
}

resource "aws_lambda_function" "kendra_source_lambda" {
  function_name    = "${var.kendra_label}-lambda-function"
  role             = aws_iam_role.kendra_source_lambda_role.arn
  handler          = "${var.kendra_source_lambda_handler_name}.lambda_handler"
  runtime          = var.runtime
  timeout          = var.timeout
  filename         = "../kendra.zip"
  source_code_hash = data.archive_file.kendra_lambda_zip.output_base64sha256
  environment {
    variables = {
      env                       = var.environment
      REGION                    = var.region,
      KENDRA_BATCH_PUT_ROLE_ARN = "aws_iam_role.kendra_batch_put.arn",
      KENDRA_INDEX_NAME         = aws_kendra_index.kendra.id,
      OVERLAP_RANGE             = var.overlap_range,
      BATCH_SIZE                = var.batch_size
    }
  }
}

data "archive_file" "langchainllm_source" {
  source_dir  = "../src/langchainllm"
  output_path = "../langchainllm.zip"
  type        = "zip"
}

resource "aws_lambda_function" "lang_chain_llm_lambda" {
  function_name    = "${var.lang_chain_llm_label}-lambda-function"
  role             = aws_iam_role.lang_chain_llm.arn
  handler          = "${var.lang_chain_llm_lambda_handler_name}.lambda_handler"
  runtime          = var.runtime
  timeout          = var.timeout
  filename         = "../langchainllm.zip"
  source_code_hash = data.archive_file.langchainllm_source.output_base64sha256
  environment {
    variables = {
      env    = var.environment
      REGION = var.region
    }
  }

  architectures = ["arm64"]
  layers = [aws_lambda_layer_version.lang_chain_llm_layer.arn]
}

resource "aws_lambda_layer_version" "lang_chain_llm_layer" {
  layer_name = "${var.lang_chain_llm_label}-layer"
  filename = "../langchain.zip"
  compatible_runtimes = [var.runtime]
  compatible_architectures = ["arm64"]
}