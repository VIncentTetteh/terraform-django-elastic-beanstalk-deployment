provider "aws" {
  region = var.region
}

# Create an S3 bucket for the Django app source code
resource "aws_s3_bucket" "django_bucket" {
  bucket = "${var.app_name}-source"
}

resource "aws_s3_bucket_object" "django_source" {
  bucket = aws_s3_bucket.django_bucket.bucket
  key    = "${var.app_name}.zip"
  source = var.source_zip
  etag   = filemd5(var.source_zip)
}

# IAM Role and Policy for Elastic Beanstalk
resource "aws_iam_role" "beanstalk_role" {
  name               = "${var.app_name}-beanstalk-role"
  assume_role_policy = data.aws_iam_policy_document.beanstalk_assume_role_policy.json
}

data "aws_iam_policy_document" "beanstalk_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "beanstalk_managed_policy" {
  role       = aws_iam_role.beanstalk_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

resource "aws_iam_instance_profile" "beanstalk_instance_profile" {
  name = "${var.app_name}-beanstalk-instance-profile"
  role = aws_iam_role.beanstalk_role.name
}

# Elastic Beanstalk Application
resource "aws_elastic_beanstalk_application" "django_app" {
  name        = var.app_name
  description = "Elastic Beanstalk Application for Django"
}

# Elastic Beanstalk Application Version
resource "aws_elastic_beanstalk_application_version" "django_app_version" {
  name = "${var.app_name}-version-label"
  application = aws_elastic_beanstalk_application.django_app.name
  bucket      = aws_s3_bucket.django_bucket.bucket
  key         = aws_s3_bucket_object.django_source.id
}

# Elastic Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "django_env" {
  name                = "${var.app_name}-env"
  application         = aws_elastic_beanstalk_application.django_app.name
  solution_stack_name = var.solution_stack_name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = var.environment_type
  }

  setting {
    namespace = "aws:elasticbeanstalk:container:python"
    name      = "NumProcesses"
    value     = var.num_processes
  }

  setting {
    namespace = "aws:elasticbeanstalk:container:python"
    name      = "NumThreads"
    value     = var.num_threads
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DJANGO_SETTINGS_MODULE"
    value     = var.django_settings_module
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PYTHONPATH"
    value     = var.python_path
  }

  version_label = aws_elastic_beanstalk_application_version.django_app_version.name
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "django_distribution" {
  origin {
    domain_name = aws_elastic_beanstalk_environment.django_env.endpoint_url
    origin_id   = "django-eb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.app_name}"
  default_root_object = ""

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "django-eb-origin"

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.django_distribution.domain_name
}

output "application_url" {
  value = aws_elastic_beanstalk_environment.django_env.endpoint_url
}
