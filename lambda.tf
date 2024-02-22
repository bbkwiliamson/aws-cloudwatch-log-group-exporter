resource aws_lambda_function sadigitalLogGroups_exporter {
  filename         = "lambda_function.zip"
  function_name    = "sadigitalLogGroups-exporter-${var.env}"
  role             = aws_iam_role.BoundedLogGroups_exporter.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 900
  memory_size      = 200 
  tags             = var.tags
  kms_key_arn      = var.kms_key_arn
  runtime = "python3.8"

  environment {
    variables = {
      S3_BUCKET = var.bucket_name,
      AWS_ACCOUNT = data.aws_caller_identity.current.account_id
    }
  }
}

