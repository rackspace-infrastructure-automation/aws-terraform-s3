output "bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = aws_s3_bucket.s3_bucket.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = aws_s3_bucket.s3_bucket.bucket_domain_name
}

output "bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region."
  value       = aws_s3_bucket.s3_bucket.hosted_zone_id
}

output "bucket_id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.s3_bucket.id
}

output "bucket_region" {
  description = "The AWS region this bucket resides in."
  value       = aws_s3_bucket.s3_bucket.region
}

output "bucket_website_domain" {
  description = "The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records."
  value       = var.website ? aws_s3_bucket.s3_bucket.website_domain : ""
}

output "bucket_website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website. If not, this will be an empty string."
  value       = var.website ? aws_s3_bucket.s3_bucket.website_endpoint : ""
}
