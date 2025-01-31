output "s3_bucket_id" {
  description = "The name of the bucket"
  value       = module.s3.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the bucket"
  value       = module.s3.s3_bucket_arn
}

output "s3_bucket_bucket_domain_name" {
  description = "The bucket domain name"
  value       = module.s3.s3_bucket_bucket_domain_name
}

output "s3_bucket_bucket_regional_domain_name" {
  description = "The bucket region-specific domain name"
  value       = module.s3.s3_bucket_bucket_regional_domain_name
}

output "s3_bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region"
  value       = module.s3.s3_bucket_hosted_zone_id
}

output "s3_bucket_region" {
  description = "The AWS region this bucket resides in"
  value       = module.s3.s3_bucket_region
}

output "s3_bucket_website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website"
  value       = module.s3.s3_bucket_website_endpoint
}

output "s3_bucket_website_domain" {
  description = "The domain of the website endpoint, if the bucket is configured with a website"
  value       = module.s3.s3_bucket_website_domain
}
