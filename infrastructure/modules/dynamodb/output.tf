output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = module.dynamodb_table.dynamodb_table_arn
}
