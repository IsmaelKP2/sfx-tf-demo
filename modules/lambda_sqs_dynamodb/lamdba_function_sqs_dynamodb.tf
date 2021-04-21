# ### Lambda Function Code
# ## Terafrom generates the lambda function from a zip file which is pulled down 
# ## from a separate repo defined in variables.tf in root folder
# resource "null_resource" "lamdba_function_lamdba_sqs_dynamodb_file" {
#   provisioner "local-exec" {
#     command = "curl -o lamdba_sqs_dynamodb_function.py ${var.function_lamdba_sqs_dynamodb_url}"
#   }
#   provisioner "local-exec" {
#     when    = destroy
#     command = "rm lamdba_sqs_dynamodb_function.py && rm lamdba_sqs_dynamodb.zip"
#   }
# }

### Create a local zip file containing lambda function code so we can upload to AWS
data "archive_file" "lamdba_sqs_dynamodb_zip" {
  type         = "zip"
  source_file  = "${path.module}/lamdba_sqs_dynamodb_function.py"
  output_path  = "${path.module}/lamdba_sqs_dynamodb.zip"
}

### Create Lambda Function ###
resource "aws_lambda_function" "lamdba_sqs_dynamodb" {
  filename      = "${path.module}/lamdba_sqs_dynamodb.zip"
  function_name = "${var.environment}_Lambda_SQS_DynamoDB"
  role          = aws_iam_role.lambda_sqs_dynamodb_role.arn
  handler       = "lamdba_sqs_dynamodb_function.lambda_handler"
  layers        = [var.region_wrapper_python]
  runtime       = "python3.7"
  timeout       = var.function_timeout

  environment {
    variables = {
      DYNAMODB_TABLE           = "${var.environment}-messages"
      MAX_QUEUE_MESSAGES       = "10"
      QUEUE_NAME               = "${var.environment}-messages"
      SIGNALFX_ACCESS_TOKEN    = var.access_token
      SIGNALFX_APM_ENVIRONMENT = var.environment
      SIGNALFX_METRICS_URL     = "https://ingest.${var.realm}.signalfx.com"
      SIGNALFX_TRACING_URL     = "https://ingest.${var.realm}.signalfx.com/v2/trace"
    }
  }
}


resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = 1
  event_source_arn  = aws_sqs_queue.messages_queue.arn
  enabled           = true
  function_name     = aws_lambda_function.lamdba_sqs_dynamodb.arn
}