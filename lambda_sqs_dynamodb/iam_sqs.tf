resource "aws_iam_policy" "tfdemo_lambda_sqs_dynamodb_policy" {
  name_prefix   = "${var.name_prefix}_lambda_sqs_dynamodb_pol_"
  description   = "Policy used by the Lambda SQS DynamoDB Role for TFDemo"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:*",
                "sqs:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "tfdemo_lambda_sqs_dynamodb_role" {
  # name_prefix = "tfdemo_lambda_sqs_dynamodb_role_"
  name_prefix = "${var.name_prefix}_lambda_sqs_dynamodb_"
    
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tfdemo_lambda_sqs_dynamodb_attach" {
  role       = aws_iam_role.tfdemo_lambda_sqs_dynamodb_role.name
  policy_arn = aws_iam_policy.tfdemo_lambda_sqs_dynamodb_policy.arn
}