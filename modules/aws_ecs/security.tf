# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "tfdemo_ecs_lb_sg" {
  name        = "tfdemo_ecs_lb_sg"
  description = "Controls access to the ECS ALB"
  vpc_id      = aws_vpc.tfdemo_ecs_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = var.ecs_app_port
    to_port     = var.ecs_app_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "tfdemo_ecs_tasks_sg" {
  name        = "tfdemo_ecs_tasks_sg"
  description = "Allow inbound access from the ECS ALB only"
  vpc_id      = aws_vpc.tfdemo_ecs_vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = var.ecs_app_port
    to_port         = var.ecs_app_port
    security_groups = [aws_security_group.tfdemo_ecs_lb_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

