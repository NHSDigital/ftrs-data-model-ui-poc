variable "subnet_ids" {
  description = "List of subnet IDs"
}

variable "security_group_ids" {
  description = "List of security group IDs"
}

variable "function_name" {
  description = "Name of the lambda function"
}

variable "env_vars" {
  description = "Map of environment variables"
  type        = map(any)
  default = {
    "service" = "ftrs",
    "profile" = "poc"
  }
}

variable "timeout" {
  description = "Timeout of the lambda function in seconds"
  default     = "900"
}

variable "retry_attempts" {
  description = "Number of retries for the lamdba"
  default     = 0
}

variable "log_retention" {
  description = "Length of timeto keep the logs in cloudwatch"
  default     = "0"
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  default     = "128"
}

variable "lambda_s3_bucket" {
  description = "The name of the S3 bucket where the Lambda function code is stored"
}

variable "lambda_s3_key" {
  description = "The S3 key (file path) for the Lambda function deployment package"
}

variable "lambda_layer_s3_key" {
  description = "The S3 key (file path) for the Lambda layer deployment package"
}

variable "lambda_handler" {
  description = "The handler for the Lambda function"
}

variable "lambda_runtime" {
  description = "The runtime environment for the Lambda function"
}

variable "lambda_layer_name" {
  description = "The name of the Lambda layer"
}

variable "lambda_s3_bucket_arn" {
  description = "The ARN of the S3 bucket where the Lambda function code is stored"
}

variable "lambda_layer_s3_bucket" {
  description = "The name of the S3 bucket where the Lambda layer code is stored"
}
