variable "table_name" {
  description = "The name of the DynamoDB table"
}

variable "hash_key" {
  description = "The primary key attribute name for the DynamoDB table"
  default     = "id"
}

variable "autoscaling_enabled" {
  description = "Specifies whether autoscaling is enabled for the DynamoDB table"
  default     = true
}

variable "stream_enabled" {
  description = "Specifies whether DynamoDB Streams are enabled for the table"
  default     = true
}

variable "stream_view_type" {
  description = "The type of view for DynamoDB Streams, defining the information captured"
  default     = "NEW_AND_OLD_IMAGES"
}

variable "attributes" {
  description = "Defines the attributes for the DynamoDB table schema, including their names and types"
  default = [
    {
      name = "id"
      type = "S"
    }
  ]
}
