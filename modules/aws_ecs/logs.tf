# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "${var.environment}/ecs"
  retention_in_days = 30

  tags = {
    Name = "${var.environment}_ecs_log_group"
  }
}

resource "aws_cloudwatch_log_stream" "ecs_log_stream" {
  name           = "${var.environment}_ecs_log_stream"
  log_group_name = aws_cloudwatch_log_group.ecs_log_group.name
}

