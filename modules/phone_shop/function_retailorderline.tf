### Lambda Function Code
## Terafrom generates the lambda function from a zip file which is pulled down 
## from a separate repo defined in varibales.tf in root folder
resource "null_resource" "retailorderline_lambda_function_file" {
  provisioner "local-exec" {
    command = "curl -o retailorderline_lambda_function.py ${var.function_retailorderline_url}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm retailorderline_lambda_function.py && rm retailorderline_lambda.zip"
  }
}

data "archive_file" "retailorderline_lambda_zip" {
  type        = "zip"
  source_file  = "retailorderline_lambda_function.py"
  output_path = "retailorderline_lambda.zip"
  depends_on = [null_resource.retailorderline_lambda_function_file]
}

### Create Lambda Function ###
resource "aws_lambda_function" "retailorderline" {
  filename      = "retailorderline_lambda.zip"
  function_name = "${var.environment}_RetailOrderLine"
  role          = aws_iam_role.lambda_role.arn
  handler       = "retailorderline_lambda_function.lambda_handler"
  layers        = [aws_lambda_layer_version.request-opentracing_2_0.arn, var.region_wrapper_python]
  runtime       = "python3.8"
  timeout       = var.function_timeout

  environment {
    variables = {
      LAMBDA_FUNCTION_NAME     = "${var.environment}_RetailOrder"
      SIGNALFX_ACCESS_TOKEN    = var.access_token
      SIGNALFX_APM_ENVIRONMENT = var.environment
      SIGNALFX_METRICS_URL     = "https://ingest.${var.realm}.signalfx.com"
      SIGNALFX_TRACING_URL     = "https://ingest.${var.realm}.signalfx.com/v2/trace"
    }
  }
}
