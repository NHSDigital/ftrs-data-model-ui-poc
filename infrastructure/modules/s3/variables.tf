variable "bucket_name" {
  description = "The name of the S3 bucket"
}

variable "attach_policy" {
  description = "Specifies whether to attach a policy to the S3 bucket"
  type        = bool
  default     = false
}

variable "policy" {
  description = "The IAM policy to attach to the S3 bucket"
  default     = null
}

variable "lifecycle_rule_inputs" {
  description = "A list of lifecycle rule configurations for managing S3 bucket objects"
  default     = []
}

variable "force_destroy" {
  description = "Indicates whether to forcibly delete the bucket and its contents during destruction"
  type        = bool
  default     = false
}

variable "target_access_logging_bucket" {
  description = "The name of the bucket where server access logs will be stored"
  default     = null
}

variable "target_access_logging_prefix" {
  description = "A prefix for the keys of all log objects in the logging target bucket"
  default     = null
}

variable "block_public_acls" {
  description = "Specifies whether to block public ACLs for the bucket"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Specifies whether to block public bucket policies"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Specifies whether to ignore public ACLs"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Specifies whether to restrict public and cross-account access when the bucket has public policies or ACLs"
  type        = bool
  default     = true
}

variable "website_map" {
  description = "A map containing configuration for static website hosting"
  default     = {}
}

variable "s3_versioning" {
  description = "Specifies whether versioning is enabled for the S3 bucket"
  type        = bool
  default     = false
}
