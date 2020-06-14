data "archive_file" "image_processor_lambda_archive" {
  type        = "zip"
  source_file = "functions/image_processor.py"
  output_path = "functions/image_processor.zip"
}

data "archive_file" "temp_url_lambda_archive" {
  type        = "zip"
  source_file = "functions/temp_url.py"
  output_path = "functions/temp_url.zip"
}

resource "aws_iam_role" "temp_url_lambda_exec_role" {
  name = "temp_url_lambda_exec_role"
  assume_role_policy = file("trust-policy.json")
}

resource "aws_iam_role" "image_processor_lambda_exec_role" {
  name = "image_processor_lambda_exec_role"
  assume_role_policy = file("trust-policy.json")
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.image_rekognition_file_upload_bucket.arn
}

resource "aws_lambda_function" "image_processor_lambda" {
  filename         = "functions/image_processor.zip"
  function_name    = "image_processor_lambda"
  role             = aws_iam_role.image_processor_lambda_exec_role.arn
  handler          = "image_processor.handler"
  runtime          = "python3.7"
  timeout          = 10
  memory_size      = 128
  source_code_hash = data.archive_file.image_processor_lambda_archive.output_base64sha256
  depends_on = [aws_iam_role_policy_attachment.image_processor_lambda_policy_attachment, aws_cloudwatch_log_group.image_processor_lambda_group]
}

resource "aws_lambda_function" "temp_url_lambda" {
  filename         = "functions/temp_url.zip"
  function_name    = "temp_url_lambda"
  role             = aws_iam_role.temp_url_lambda_exec_role.arn
  handler          = "temp_url.handler"
  runtime          = "python3.7"
  timeout          = 10
  memory_size      = 128
  source_code_hash = data.archive_file.temp_url_lambda_archive.output_base64sha256
  environment {
    variables = {
      IMAGE_REKOGNITION_UPLOAD_BUCKET_NAME = aws_s3_bucket.image_rekognition_file_upload_bucket.id
      IMAGE_REKOGNITION_UPLOAD_EXPIRATION  = var.s3_tempory_upload_expiration
    }
  }
  depends_on = [aws_iam_role_policy_attachment.temp_url_lambda_policy_attachment, aws_cloudwatch_log_group.temp_url_lambda_group]
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.temp_url_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.temp_url_api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.image_rekognition_file_upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_cloudwatch_log_group" "image_processor_lambda_group" {
  name              = "/aws/lambda/image_processor_lambda"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "temp_url_lambda_group" {
  name              = "/aws/lambda/temp_url_lambda"
  retention_in_days = 14
}

resource "aws_iam_policy" "image_processor_lambda_policy" {
  name        = "image_processor_lambda_policy"
  path        = "/"
  description = "IAM policy for logging and rekognition from a lambda"

  policy = file("image-processor-access-policy.json")
}

resource "aws_iam_policy" "temp_url_lambda_policy" {
  name        = "temp_url_lambda_policy"
  path        = "/"
  description = "IAM policy for logging and s3 bucket url generation from a lambda"

  policy = file("temp-url-access-policy.json")
}

resource "aws_iam_role_policy_attachment" "image_processor_lambda_policy_attachment" {
  role       = aws_iam_role.image_processor_lambda_exec_role.name
  policy_arn = aws_iam_policy.image_processor_lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "temp_url_lambda_policy_attachment" {
  role       = aws_iam_role.temp_url_lambda_exec_role.name
  policy_arn = aws_iam_policy.temp_url_lambda_policy.arn
}