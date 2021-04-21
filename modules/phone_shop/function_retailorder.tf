### Lambda Function Code
## Terafrom generates the lambda function from a zip file which is pulled down 
## from a separate repo defined in varibales.tf in root folder
resource "null_resource" "retailorder_lambda_function_file" {
  provisioner "local-exec" {
    command = "curl -o retailorder_lambda_function.py ${var.function_retailorder_url}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm retailorder_lambda_function.py && rm retailorder_lambda.zip"
  }
}

data "archive_file" "retailorder_lambda_zip" {
  type         = "zip"
  source_file  = "retailorder_lambda_function.py"
  output_path  = "retailorder_lambda.zip"
  depends_on   = [null_resource.retailorder_lambda_function_file]
}

### Create Lambda Function ###
resource "aws_lambda_function" "retailorder" {
  filename      = "retailorder_lambda.zip"
  function_name = "${var.environment}_RetailOrder"
  role          = aws_iam_role.lambda_role.arn
  handler       = "retailorder_lambda_function.lambda_handler"
  # layers        = [aws_lambda_layer_version.request-opentracing_2_0.arn, var.region_wrapper_python]
  layers        = [var.region_wrapper_python]
  runtime       = "python3.8"
  timeout       = var.function_timeout

  environment {
    variables = {
      ORDER_LINE               = aws_lambda_function.retailorderline.arn
      PRICE_URL                = aws_api_gateway_deployment.retailorderprice.invoke_url
      SIGNALFX_ACCESS_TOKEN    = var.access_token
      SIGNALFX_APM_ENVIRONMENT = var.environment
      SIGNALFX_METRICS_URL     = "https://ingest.${var.realm}.signalfx.com"
      SIGNALFX_TRACING_URL     = "https://ingest.${var.realm}.signalfx.com/v2/trace"
    }
  }
}

### API Gateway Proxy ###
## Imports id's from the API gateway created by api_gateway.tf
## The special path_part value "{proxy+}" activates proxy behavior, 
## which means that this resource will match any request path
resource "aws_api_gateway_resource" "retailorder_proxy" {
  rest_api_id = aws_api_gateway_rest_api.retailorder.id
  parent_id   = aws_api_gateway_rest_api.retailorder.root_resource_id
  path_part   = "{retailorder_proxy+}"
}

### API Gateway Method ###
## Uses a http_method of "ANY", which allows any request method to be used.
## Working in conjunction with the proxy+ setting above means that all 
## incoming requests will match this resource
resource "aws_api_gateway_method" "retailorder_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.retailorder.id
  resource_id   = aws_api_gateway_resource.retailorder_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

### API Routing to Lambda ###
## Specifes that requests to method are sent to the Lambda Function
resource "aws_api_gateway_integration" "retailorder_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.retailorder.id
  resource_id             = aws_api_gateway_method.retailorder_proxy.resource_id
  http_method             = aws_api_gateway_method.retailorder_proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.retailorder.invoke_arn
}

### API Routing for proxy_root###
## The AWS_PROXY integration type causes API gateway to call into the API of another AWS service.
## In this case, it will call the AWS Lambda API to create an "invocation" of the Lambda function.
## Unfortunately the proxy resource cannot match an empty path at the root of the API. 
## To handle that, a similar configuration must be applied to the root resource that is built in to the REST API object:
resource "aws_api_gateway_method" "retailorder_proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.retailorder.id
  resource_id   = aws_api_gateway_rest_api.retailorder.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "retailorder_lambda_root" {
  rest_api_id             = aws_api_gateway_rest_api.retailorder.id
  resource_id             = aws_api_gateway_method.retailorder_proxy_root.resource_id
  http_method             = aws_api_gateway_method.retailorder_proxy_root.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.retailorder.invoke_arn
}

### Activate and expose API Gateway ###
## Create an API Gateway "deployment" in order to activate the configuration and 
## expose the API at a URL that can be used for testing.
resource "aws_api_gateway_deployment" "retailorder" {
  depends_on = [
    aws_api_gateway_integration.retailorder_lambda,
    aws_api_gateway_integration.retailorder_lambda_root,
  ]
  rest_api_id = aws_api_gateway_rest_api.retailorder.id
  stage_name  = "default"
}

### Grant Lambda Access to API Gateway ###
## By default an AWS services does not have access to another service, 
## until access is explicitly granted.
resource "aws_lambda_permission" "retailorder_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.retailorder.function_name
  principal     = "apigateway.amazonaws.com"
  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn    = "${aws_api_gateway_rest_api.retailorder.execution_arn}/*/*"
}
