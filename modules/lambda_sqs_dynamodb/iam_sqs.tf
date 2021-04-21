resource "aws_iam_policy" "lambda_sqs_dynamodb_policy" {
  name_prefix   = "${var.environment}_lambda_sqs_dynamodb_pol_"
  description   = "Policy used by the Lambda SQS DynamoDB Role for ${var.environment}"

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

resource "aws_iam_role" "lambda_sqs_dynamodb_role" {
  name_prefix = "${var.environment}_lambda_sqs_dynamodb_"
    
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

resource "aws_iam_role_policy_attachment" "lambda_sqs_dynamodb_attach" {
  role       = aws_iam_role.lambda_sqs_dynamodb_role.name
  policy_arn = aws_iam_policy.lambda_sqs_dynamodb_policy.arn
}