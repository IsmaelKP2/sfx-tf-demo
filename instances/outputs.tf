output "smart_gateway1_private_ip" {
  value = "${aws_instance.smart-gateway1.*.private_ip}"
  description = "The Private IP address assigned to the Smart-Gateway1"
}


output "smart_gateway2_private_ip" {
  value = "${aws_instance.smart-gateway2.*.private_ip}"
  description = "The Private IP address assigned to the Smart-Gateway2"
}