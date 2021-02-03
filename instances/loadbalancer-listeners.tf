resource "aws_lb_listener" "collector-lb-listener-9411" {
  default_action {
    target_group_arn = aws_lb_target_group.collector-lb-tg-9411.arn
    type = "forward"
  }
  load_balancer_arn = aws_lb.collector-lb.arn
  port = 9411
  protocol = "HTTP"
}

resource "aws_lb_listener_rule" "rule-9411" {
  listener_arn = aws_lb_listener.collector-lb-listener-9411.id
  priority = 100

  action {
    target_group_arn = aws_lb_target_group.collector-lb-tg-9411.arn
    type = "forward"
  }

  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }
}





resource "aws_lb_listener" "collector-lb-listener-9943" {
  default_action {
    target_group_arn = aws_lb_target_group.collector-lb-tg-9943.arn
    type = "forward"
  }
  load_balancer_arn = aws_lb.collector-lb.arn
  port = 9943
  protocol = "HTTP"
}

resource "aws_lb_listener_rule" "rule-9943" {
  listener_arn = aws_lb_listener.collector-lb-listener-9943.id
  priority = 100

  action {
    target_group_arn = aws_lb_target_group.collector-lb-tg-9943.arn
    type = "forward"
  }

  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }
}

resource "aws_lb_listener" "collector-lb-listener-6060" {
  default_action {
    target_group_arn = aws_lb_target_group.collector-lb-tg-6060.arn
    type = "forward"
  }
  load_balancer_arn = aws_lb.collector-lb.arn
  port = 6060
  protocol = "HTTP"
}

resource "aws_lb_listener_rule" "rule-6060" {
  listener_arn = aws_lb_listener.collector-lb-listener-6060.id
  priority = 100

  action {
    target_group_arn = aws_lb_target_group.collector-lb-tg-6060.arn
    type = "forward"
  }

  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }
}



resource "aws_lb_listener" "collector-lb-listener-7276" {
  default_action {
    target_group_arn = aws_lb_target_group.collector-lb-tg-7276.arn
    type = "forward"
  }
  load_balancer_arn = aws_lb.collector-lb.arn
  port = 7276
  protocol = "HTTP"
}

resource "aws_lb_listener_rule" "rule-7276" {
  listener_arn = aws_lb_listener.collector-lb-listener-7276.id
  priority = 100

  action {
    target_group_arn = aws_lb_target_group.collector-lb-tg-7276.arn
    type = "forward"
  }

  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }
}