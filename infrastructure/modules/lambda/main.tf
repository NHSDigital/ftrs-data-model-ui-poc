data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_execution_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name   = "${var.function_name}-policy"
  role   = aws_iam_role.iam_for_lambda.name
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "${var.lambda_s3_bucket_arn}"
    }
  ]
}
POLICY
}

resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name          = var.lambda_layer_name
  compatible_runtimes = [var.lambda_runtime]

  s3_bucket = var.lambda_s3_bucket
  s3_key    = var.lambda_layer_s3_key
}

resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda.arn
  s3_bucket     = var.lambda_s3_bucket
  s3_key        = var.lambda_s3_key
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime

  publish      = true
  package_type = "Zip"
  timeout      = var.timeout
  memory_size  = var.memory_size

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = var.env_vars
  }

  layers = [
    aws_lambda_layer_version.lambda_layer.arn
  ]

  depends_on = [
    aws_cloudwatch_log_group.lambda_log_group
  ]
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention
}
