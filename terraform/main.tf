provider "aws" {
  region = var.aws_region
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_weather_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach IAM Policies
resource "aws_iam_policy_attachment" "lambda_basic" {
  name       = "lambda-basic"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "lambda_s3_access" {
  name       = "lambda-s3-access"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Lambda Function from S3
resource "aws_lambda_function" "weather" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  s3_bucket = var.s3_bucket
  s3_key    = "lambda-packages/lambda/lambda_function.zip"

  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")

  environment {
    variables = {
      WEATHER_API_KEY = var.weather_api_key
      LOCATION        = var.location
      BUCKET_NAME     = var.bucket_name
    }
  }
}


# EventBridge Rule to Trigger Lambda Every Minute
resource "aws_cloudwatch_event_rule" "every_1_min" {
  name                = "run-weather-lambda-every-1min"
  description         = "Trigger Lambda function every 1 minute"
  schedule_expression = "rate(1 minute)"
}

# Permission for EventBridge to Invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.weather.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_1_min.arn
}

# Link Lambda with Event Rule
resource "aws_cloudwatch_event_target" "lambda_trigger" {
  rule      = aws_cloudwatch_event_rule.every_1_min.name
  target_id = "weather-lambda"
  arn       = aws_lambda_function.weather.arn
}
