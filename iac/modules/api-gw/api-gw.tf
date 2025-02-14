resource "aws_apigatewayv2_api" "api_gateway" {
    name          = "my-edge-api-gateway"
    protocol_type = "HTTP"
    target        = "EDGE"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
    api_id            = aws_apigatewayv2_api.api_gateway.id
    integration_type  = "AWS_PROXY"
    integration_uri   = aws_lambda_function.lambda_function.invoke_arn
    integration_method = "POST"
}

resource "aws_apigatewayv2_route" "message_route" {
    api_id    = aws_apigatewayv2_api.api_gateway.id
    route_key = "/message"
    target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "health_route" {
    api_id    = aws_apigatewayv2_api.api_gateway.id
    route_key = "/health"
    target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_function" "lambda_function" {
    function_name = "my-lambda-function"
    role          = aws_iam_role.lambda_role.arn
    handler       = "index.handler"
    runtime       = "nodejs14.x"
    filename      = "lambda_function.zip"
}

resource "aws_iam_role" "lambda_role" {
    name = "my-lambda-role"

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