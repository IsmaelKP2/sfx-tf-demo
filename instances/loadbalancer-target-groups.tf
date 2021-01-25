resource "aws_lb_target_group" "collector-lb-tg" {
  name     = "collector-lb-tg"
  port     = 9943
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
#   lifecycle { create_before_destroy=true }

  health_check {
    path = "/"
    port = 13133
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"  # has to be HTTP 200 or fails
  }
}

resource "aws_lb_target_group_attachment" "collector-lb-tg-attachment" {
  count            = var.collector_count
  target_group_arn = aws_lb_target_group.collector-lb-tg.arn
  target_id        = aws_instance.collector[count.index].id
  port             = 9943
}