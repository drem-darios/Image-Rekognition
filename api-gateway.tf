# API Gateway
resource "aws_api_gateway_rest_api" "temp_url_api" {
  name = "temp_url_api"
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "temp-url"
  parent_id   = aws_api_gateway_rest_api.temp_url_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.temp_url_api.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.temp_url_api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_stage" "temp_url_dev_stage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.temp_url_api.id
  deployment_id = aws_api_gateway_deployment.temp_url_dev_deployment.id
}

resource "aws_api_gateway_deployment" "temp_url_dev_deployment" {
  depends_on  = [aws_api_gateway_integration.integration]
  rest_api_id = aws_api_gateway_rest_api.temp_url_api.id
  stage_name  = "dev"
}

resource "aws_api_gateway_method_settings" "temp_url_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.temp_url_api.id
  stage_name  = aws_api_gateway_stage.temp_url_dev_stage.stage_name
  method_path = "${aws_api_gateway_resource.resource.path_part}/${aws_api_gateway_method.method.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.temp_url_api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.temp_url_lambda.invoke_arn
}
