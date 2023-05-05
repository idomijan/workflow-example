# Create an S3 bucket for input files
resource "aws_s3_bucket" "input_bucket" {
  bucket = "my-input-bucket"
  acl    = "private"
}

# Create an S3 bucket for processed files
resource "aws_s3_bucket" "output_bucket" {
  bucket = "my-output-bucket"
  acl    = "private"
}

# Create an SQS queue for file processing messages
resource "aws_sqs_queue" "file_queue" {
  name = "my-file-queue"
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  # Allow access to S3, SQS, SNS, and CloudWatch Logs
  inline_policy {
    name = "lambda-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["s3:GetObject"]
          Resource = "${aws_s3_bucket.input_bucket.arn}/*"
        },
        {
          Effect   = "Allow"
          Action   = ["s3:PutObject"]
          Resource = "${aws_s3_bucket.output_bucket.arn}/*"
        },
        {
          Effect   = "Allow"
          Action   = ["sqs:*"]
          Resource = "${aws_sqs_queue.file_queue.arn}"
        },
        {
          Effect   = "Allow"
          Action   = ["sns:Publish"]
          Resource = "${aws_sns_topic.data_topic.arn}"
        },
        {
          Effect   = "Allow"
          Action   = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

# Create an IAM role for the Fargate task
resource "aws_iam_role" "fargate_role" {
  name = "fargate-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  # Allow access to S3, SQS, SNS, and CloudWatch Logs
  inline_policy {
    name = "fargate-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["s3:GetObject"]
          Resource = "${aws_s3_bucket.input_bucket.arn}/*"
        },
        {
          Effect   = "Allow"
          Action   = ["s3:PutObject"]
          Resource = "${aws_s3_bucket.output_bucket.arn}/*"
        },
        {
          Effect   = "Allow"
          Action   = ["sqs:*"]
          Resource = "${aws_sqs_queue.file_queue.arn}"
        },
        {
          Effect   = "Allow"
          Action   = ["sns:Publish"]
          Resource
