output "ecs_alb_hostname" {
  # value = aws_alb.ecs_lb.dns_name
  value = join("",["http://", aws_alb.ecs_lb.dns_name, ":", var.ecs_app_port])
}
