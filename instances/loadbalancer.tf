resource "aws_lb" "collector-lb" {
  name                = "collector-lb"
  internal            = true
  load_balancer_type  = "application"
  security_groups      = [
    var.allow_collectors_id,
    ]
  subnets = var.subnet_ids

  enable_deletion_protection = false

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.bucket
#     prefix  = "test-lb"
#     enabled = true
#   }

#   tags = {
#     Environment = "production"
#   }
}
