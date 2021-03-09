output "ecs_alb_hostname" {
  value = aws_alb.tfdemo_ecs_lb.dns_name
}

## consider adding join to add the port to the output value