# main.tf

# Provider configuration
provider "aws" {
    region = "us-west-2"
}

# Lambda function for health check
resource "aws_lambda_function" "health_check_lambda" {
    function_name = "health-check-lambda"
    role          = aws_iam_role.lambda_role.arn
    handler       = "index.handler"
    runtime       = "nodejs14.x"
    timeout       = 10

    # Add your lambda code here
    # e.g., filename = "health_check_lambda.js"
    #      source_code_hash = filebase64sha256(filename)
    #      source_code_hash = filebase64sha256(filename)
}

# Lambda function for messaging and retrieve/generate from the kb
resource "aws_lambda_function" "messaging_lambda" {
    function_name = "messaging-lambda"
    role          = aws_iam_role.lambda_role.arn
    handler       = "index.handler"
    runtime       = "nodejs14.x"
    timeout       = 10

    # Add your lambda code here
    # e.g., filename = "messaging_lambda.js"
    #      source_code_hash = filebase64sha256(filename)
}

# IAM role for the lambdas
resource "aws_iam_role" "lambda_role" {
    name = "lambda-role"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

# IAM policy for the lambdas
resource "aws_iam_policy" "lambda_policy" {
    name        = "lambda-policy"
    description = "Policy for lambda functions"

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
        }
    ]
}
EOF
}

# Attach IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
    policy_arn = aws_iam_policy.lambda_policy.arn
    role       = aws_iam_role.lambda_role.name
}