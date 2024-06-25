variable "region" {
  description = "The AWS region to deploy the application"
  type        = string
  default     = "us-west-2"
}

variable "app_name" {
  description = "The name of the Elastic Beanstalk application"
  type        = string
}

variable "solution_stack_name" {
  description = "The solution stack to use for the Elastic Beanstalk environment"
  type        = string
  default     = "64bit Amazon Linux 2 v3.1.5 running Python 3.8"
}

variable "instance_type" {
  description = "The instance type to use for the EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "environment_type" {
  description = "The environment type for the Elastic Beanstalk environment"
  type        = string
  default     = "SingleInstance"
}

variable "num_processes" {
  description = "The number of processes to run on each instance"
  type        = string
  default     = "1"
}

variable "num_threads" {
  description = "The number of threads to run on each instance"
  type        = string
  default     = "15"
}

variable "django_settings_module" {
  description = "The Django settings module"
  type        = string
  default     = "myapp.settings"
}

variable "python_path" {
  description = "The Python path for the Django application"
  type        = string
  default     = "/var/app/current"
}

variable "source_zip" {
  description = "The path to the source zip file for the Django application"
  type        = string
}
