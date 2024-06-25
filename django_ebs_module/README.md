# Django Elastic Beanstalk Module with CloudFront

This Terraform module deploys a Django application on AWS Elastic Beanstalk, sets up a CloudFront distribution, and returns the URLs to the deployed resources.

## Usage

```hcl
module "django_ebs" {
  source = "./django_ebs_module"

  region                 = "us-west-2"
  app_name               = "my-django-app"
  solution_stack_name    = "64bit Amazon Linux 2 v3.1.5 running Python 3.8"
  instance_type          = "t3.micro"
  environment_type       = "SingleInstance"
  num_processes          = "1"
  num_threads            = "15"
  django_settings_module = "myapp.settings"
  python_path            = "/var/app/current"
  source_zip             = "path/to/your/django-app.zip"
}

output "cloudfront_url" {
  value = module.django_ebs.cloudfront_url
}

output "application_url" {
  value = module.django_ebs.application_url
}
