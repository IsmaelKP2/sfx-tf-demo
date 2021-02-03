output "retailorder_rest_api_id" {
    value = aws_api_gateway_rest_api.retailorder.*.id
}

output "retailorder_root_resource_id" {
  value = aws_api_gateway_rest_api.retailorder.*.root_resource_id
}

output "aws_api_gateway_rest_api_execution_arn" {
  value = aws_api_gateway_rest_api.retailorder.*.execution_arn
}

### WHY DO I STILL HAVE THE * IN THE ABOVE WHEN THE ONE BELOW FAILED WITH IT - NEED TO TEST ###

output "aws_api_gateway_deployment_retailorder_invoke_url" {
  value = aws_api_gateway_deployment.retailorder.invoke_url
}