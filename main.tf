# 1. Provider Setup
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_iam_role" "lambda_role" {
 name   = "terraform_aws_lambda_role"
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

provider "aws" {
  region = "us-east-1"
}

# 2. Package local code automatically
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.cwd}/python/helloworld.py" # Path to your source code
  output_path = "lambda_function.zip"
}


resource "aws_lambda_function" "terraform_lambda_func" {
 filename                       = "${path.module}/python/helloworld.zip"
 function_name                  = "PythonLambdaTest"
 role                           = aws_iam_role.lambda_role.arn
 handler                        = "helloworld.lambda_handler"
 runtime                        = "python3.8"
 depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name         = "aws_iam_policy_for_terraform_aws_lambda_role"
  path         = "/"
  description  = "AWS IAM Policy for managing aws lambda role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Attach basic execution policy (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

output "terraform_aws_role_output" {
 value = aws_iam_role.lambda_role.name
}

output "terraform_aws_role_arn_output" {
 value = aws_iam_role.lambda_role.arn
}

output "terraform_logging_arn_output" {
 value = aws_iam_policy.iam_policy_for_lambda.arn
}