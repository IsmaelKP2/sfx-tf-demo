### Lambda Function Code
## Terafrom generates the lambda function from a zip file which is pulled down 
## from a separate repo defined in varibales.tf in root folder
resource "null_resource" "retailorderprice_lambda_function_file" {
  provisioner "local-exec" {
    command = "curl -o retailorderprice_index.js ${var.function_retailorderprice_url}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm retailorderprice_index.js && rm retailorderprice_lambda.zip"
  }
}

data "archive_file" "retailorderprice_lambda_zip" {
  type         = "zip"
  source_file  = "retailorderprice_index.js"
  output_path  = "retailorderprice_lambda.zip"
  depends_on   = [null_resource.retailorderprice_lambda_function_file]
}

### Create Lambda Function ###
resource "aws_lambda_function" "retailorderprice" {
  filename      = "retailorderprice_lambda.zip"
  function_name = "${var.environment}_RetailOrderPrice"
  role          = aws_iam_role.lambda_role.arn
  handler       = "retailorderprice_index.handler"
  layers        = [var.region_wrapper_nodejs]
  runtime       = "nodejs12.x"
  timeout       = var.function_timeout

  environment {
    variables = {
      DISCOUNT_HOST            = aws_ssm_parameter.retaildiscount_invoke_url.value
      DISCOUNT_PATH            = aws_ssm_parameter.retailorderdiscount_path.value
      SIGNALFX_ACCESS_TOKEN    = var.access_token
      SIGNALFX_APM_ENVIRONMENT = var.environment
      SIGNALFX_METRICS_URL     = "https://ingest.${var.realm}.signalfx.com"
      SIGNALFX_ENDPOINT_URL    = "https://ingest.${var.realm}.signalfx.com/v2/trace"
    }
  }
}

### API Gateway Proxy ###
## Imports id's from the API gateway created by api_gateway.tf
## The special path_part value "{proxy+}" activates proxy behavior, 
## which means that this resource will match any request path
resource "aws_api_gateway_resource" "retailorderprice_proxy" {
  rest_api_id = aws_api_gateway_rest_api.retailorderprice.id
  parent_id   = aws_api_gateway_rest_api.retailorderprice.root_resource_id
  path_part   = "{retailorderprice_proxy+}"
}

### API Gateway Method ###
## Uses a http_method of "ANY", which allows any request method to be used.
## Working in conjunction with the proxy+ setting above means that all 
## incoming requests will match this resource
resource "aws_api_gateway_method" "retailorderprice_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.retailorderprice.id
  resource_id   = aws_api_gateway_resource.retailorderprice_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

### API Routing to Lambda ###
## Specifes that requests to method are sent to the Lambda Function
resource "aws_api_gateway_integration" "retailorderprice_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.retailorderprice.id
  resource_id             = aws_api_gateway_method.retailorderprice_proxy.resource_id
  http_method             = aws_api_gateway_method.retailorderprice_proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.retailorderprice.invoke_arn
}

### API Routing for proxy_root###
## The AWS_PROXY integration type causes API gateway to call into the API of another AWS service.
## In this case, it will call the AWS Lambda API to create an "invocation" of the Lambda function.
## Unfortunately the proxy resource cannot match an empty path at the root of the API. 
## To handle that, a similar configuration must be applied to the root resource that is built in to the REST API object:
resource "aws_api_gateway_method" "retailorderprice_proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.retailorderprice.id
  resource_id   = aws_api_gateway_rest_api.retailorderprice.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "retailorderprice_lambda_root" {
  rest_api_id             = aws_api_gateway_rest_api.retailorderprice.id
  resource_id             = aws_api_gateway_method.retailorderprice_proxy_root.resource_id
  http_method             = aws_api_gateway_method.retailorderprice_proxy_root.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.retailorderprice.invoke_arn
}

### Activate and expose API Gateway ###
## Create an API Gateway "deployment" in order to activate the configuration and 
## expose the API at a URL that can be used for testing.
resource "aws_api_gateway_deployment" "retailorderprice" {
  depends_on = [
    aws_api_gateway_integration.retailorderprice_lambda,
    aws_api_gateway_integration.retailorderprice_lambda_root,
  ]
  rest_api_id = aws_api_gateway_rest_api.retailorderprice.id
  stage_name  = "default"
}

### Grant Lambda Access to API Gateway ###
## By default any two AWS services have no access to retailorderprice another, 
## until access is explicitly granted.
resource "aws_lambda_permission" "retailorderprice_apigwapigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.retailorderprice.function_name
  principal     = "apigateway.amazonaws.com"
  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.retailorderprice.execution_arn}/*/*"
}
