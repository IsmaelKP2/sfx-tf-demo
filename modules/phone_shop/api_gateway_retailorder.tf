### API Gateway ###
resource "aws_api_gateway_rest_api" "retailorder" {
  name  = "${var.environment}_RetailOrder_api_gateway"
}
