variable "data_model_ui_timeout" {
  description = "The timeout for the Data Model UI Lambda function"
  type        = number
}

variable "data_model_ui_memory_size" {
  description = "The memory size for the Data Model UI Lambda function"
  type        = number
}

variable "data_model_ui_db_connection_timeout" {
  description = "The connection timeout for the Data Model UI Lambda function"
  type        = number
}

variable "data_model_ui_lambda_runtime" {
  description = "The runtime environment for the Data Model UI Lambda function"
  type        = string
}

variable "data_model_ui_lambda_handler" {
  description = "The handler for the Data Model UI Lambda function"
  type        = string
}

variable "application_tag" {
  description = "The version or tag of the application zip"
  type        = string
}


