### API Gateway ###
resource "aws_api_gateway_rest_api" "retailorderdiscount" {
  name = "${var.environment}_RetailOrderDiscount_api_gateway"
}

### Trim the https:// and /default from the api invoke url and store in aws_ssm
### so we can retrieve it within function_retailorderprice.
### Using ssm_paramater as we are using count so cannot use outputs - CAN NOW REMOVE THIS AS NOT USING COUNT - TO DO!
resource "aws_ssm_parameter" "retaildiscount_invoke_url" {
  name      = "${var.environment}_retaildiscount_invoke_url"
  type      = "String"
  value     = trimsuffix(trimprefix(aws_api_gateway_deployment.retailorderdiscount.invoke_url, "https://"), "/default")
  overwrite = true
}
