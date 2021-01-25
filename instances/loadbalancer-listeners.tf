resource "aws_lb_listener" "collector-lb-listener" {
  default_action {
    target_group_arn = aws_lb_target_group.collector-lb-tg.arn
    type = "forward"
  }
  load_balancer_arn = aws_lb.collector-lb.arn
  port = 9943
  protocol = "HTTP"
}

resource "aws_lb_listener_rule" "rule-1" {
  listener_arn = aws_lb_listener.collector-lb-listener.id
  priority = 100

  action {
    target_group_arn = aws_lb_target_group.collector-lb-tg.arn
    type = "forward"
  }

  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }
}