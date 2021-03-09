resource "aws_lb" "collector-lb" {
  name                = "collector-lb"
  internal            = true
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.instances_sg.id]
  subnets = var.public_subnet_ids
  enable_deletion_protection = false
}
