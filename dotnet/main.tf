terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_iam_role" "lambda_role" {
  name = "basic-dotnet-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/publish"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "hello" {
  function_name = "basic-dotnet-lambda"
  role          = aws_iam_role.lambda_role.arn

  runtime = "dotnet10"
#   Format - assembly::fully-qualified-type::method
  handler = "dotnet::LambdaTest.LambdaHandler::handleRequest"

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
}