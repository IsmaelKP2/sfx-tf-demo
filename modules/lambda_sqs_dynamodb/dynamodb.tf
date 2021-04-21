resource "aws_dynamodb_table" "messages" {
  name           = "${var.environment}_messages"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "MessageId"

  attribute {
    name = "MessageId"
    type = "S"
  }

#   ttl {
#     attribute_name = "TimeToExist"
#     enabled        = false
#   }

  tags = {
    UserID = "sloth"
  }
}