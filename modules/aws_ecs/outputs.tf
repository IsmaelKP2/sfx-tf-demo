output "ecs_alb_hostname" {
  # value = aws_alb.tfdemo_ecs_lb.dns_name
  value = join("",["http://", aws_alb.tfdemo_ecs_lb.dns_name, ":", var.ecs_app_port])
}
