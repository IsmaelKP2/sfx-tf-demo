# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "tfdemo_ecs_log_group" {
  name              = "/ecs/tfdemo"
  retention_in_days = 30

  tags = {
    Name = "tfdemo-ecs-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "tfdemo_ecs_log_stream" {
  name           = "tfdemo-ecs-log-stream"
  log_group_name = aws_cloudwatch_log_group.tfdemo_ecs_log_group.name
}

