resource "aws_sqs_queue" "messages_queue" {
  name                       = "${var.environment}-messages"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 60
  receive_wait_time_seconds  = 0
}