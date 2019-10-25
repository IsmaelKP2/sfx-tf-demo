output "smart_gateway_private_ip" {
  value = "${aws_instance.smart-gateway.*.private_ip}"
  description = "The Private IP address assigned to the Smart-Gateway"
}