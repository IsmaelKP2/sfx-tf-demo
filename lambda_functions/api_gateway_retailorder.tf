### API Gateway ###
resource "aws_api_gateway_rest_api" "retailorder" {
  name  = "${var.name_prefix}_RetailOrder_api_gateway"
}
