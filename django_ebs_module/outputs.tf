output "cloudfront_url" {
  description = "The CloudFront URL of the deployed Django application"
  value       = aws_cloudfront_distribution.django_distribution.domain_name
}

output "application_url" {
  description = "The URL of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.django_env.endpoint_url
}
