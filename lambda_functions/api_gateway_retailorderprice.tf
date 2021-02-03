### API Gateway ###
resource "aws_api_gateway_rest_api" "retailorderprice" {
  name  = "${var.name_prefix}_RetailOrderPrice_api_gateway"
}
