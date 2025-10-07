output "s3_bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.images.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.images.arn
}

output "s3_bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.images.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "The bucket regional domain name"
  value       = aws_s3_bucket.images.bucket_regional_domain_name
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.images.id
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.images.arn
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.images.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID"
  value       = aws_cloudfront_distribution.images.hosted_zone_id
}

output "cloudfront_distribution_status" {
  description = "The current status of the distribution"
  value       = aws_cloudfront_distribution.images.status
}

output "cdn_url" {
  description = "The CDN URL for accessing images"
  value       = length(var.cloudfront_aliases) > 0 ? "https://${var.cloudfront_aliases[0]}" : "https://${aws_cloudfront_distribution.images.domain_name}"
}

output "origin_access_control_id" {
  description = "The ID of the Origin Access Control"
  value       = aws_cloudfront_origin_access_control.images.id
}

output "cache_policy_id" {
  description = "The ID of the CloudFront cache policy"
  value       = aws_cloudfront_cache_policy.images_optimized.id
}

output "response_headers_policy_id" {
  description = "The ID of the CloudFront response headers policy"
  value       = aws_cloudfront_response_headers_policy.security_headers.id
}
