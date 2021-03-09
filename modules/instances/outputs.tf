output "collector_lb_int_dns" {
  value = aws_lb.collector-lb.dns_name
  description = "The Internal DNS address assigned to the Collector Internal Load Balancer"
}
