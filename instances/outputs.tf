output "collector_lb_int_dns" {
  value = aws_lb.collector-lb.dns_name
  description = "The Internal DNS address assigned to the Collector Internal Load Balancer"
}

# output "wordpress1_public_ip" {
#   value = "${aws_instance.wordpress1.*.public_ip}"
#   description = "The Public IP address assigned to Wordpress1"
# }
# output "wordpress2_public_ip" {
#   value = "${aws_instance.wordpress2.*.public_ip}"
#   description = "The Public IP address assigned to Wordpress2"
# }