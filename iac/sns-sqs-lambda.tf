/*
Overview:
- SNS topic that will be used to send messages to the SQS queue. 
- A subscription is created to send messages to the SQS queue.
- A lambda function is created that will be triggered by the SNS topic to read messages from the SQS queue.
*/

# Create SNS topic
resource "aws_sns_topic" "sample_topic" {
  name = "sample-topic"
}

# Create SQS queue
resource "aws_sqs_queue" "sample_queue" {
  name = "sample-queue"
}

# Create SNS topic subscription to SQS queue
resource "aws_sns_topic_subscription" "sns_sqs_subscription" {
  topic_arn = aws_sns_topic.sample_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sample_queue.arn
}

# Create SNS topic subscription to Lambda
resource "aws_sns_topic_subscription" "sns_lambda_subscription" {
  topic_arn = aws_sns_topic.sample_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_function.arn
}

# Create lambda function
resource "aws_lambda_function" "lambda_function" {
  filename      = "lambda/sns-sqs-lambda/lambda_function.zip"
  function_name = "example_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  source_code_hash = filebase64sha256("lambda/sns-sqs-lambda/lambda_function.zip")
}

# Create lambda function IAM role
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_lambda_permission" "this" {
  statement_id   = "AllowExecutionFromSNS"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.lambda_function.function_name
  principal      = "sns.amazonaws.com"
  source_arn     = aws_sns_topic.sample_topic.arn
}

