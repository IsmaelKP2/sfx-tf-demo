# alb.tf

resource "aws_alb" "ecs_lb" {
  name            = "${var.environment}-ecs-lb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.ecs_lb_sg.id]
}

resource "aws_alb_target_group" "ecs_app_tg" {
  name        = "${var.environment}-ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ecs_vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.ecs_health_check_path
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.ecs_lb.id
  port              = var.ecs_app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.ecs_app_tg.id
    type             = "forward"
  }
}

