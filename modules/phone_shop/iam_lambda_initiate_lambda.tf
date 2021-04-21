resource "aws_iam_role" "lambda_role" {
  name_prefix = "${var.environment}_lambda_role_"
  
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

# output "lambda_role_arn" {
#   value = aws_iam_role.lambda_role.arn
# }

resource "aws_iam_policy" "lambda_initiate_lambda_policy" {
  name_prefix   = "${var.environment}_lambda_initiate_lambda_"
  description   = "Policy used by the Lambda Initiate Lambda Role for Splunk APM Demo"

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
                "lambda:InvokeFunction",
                "lambda:InvokeAsync"
            ],
            "Resource": "arn:aws:lambda:*:*:function:*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_initiate_lambda_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_initiate_lambda_policy.arn
}
