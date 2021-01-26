resource "aws_lb" "collector-lb" {
  name                = "collector-lb"
  internal            = true
  load_balancer_type  = "application"
  security_groups      = [
    var.sg_collectors_id,
    ]
  subnets = var.subnet_ids

  enable_deletion_protection = false
}
