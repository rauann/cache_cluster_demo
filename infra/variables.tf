variable "name" {
  type        = string
  description = "Name of the application"
  default     = "cache-cluster-demo"
}

variable "environment_name" {
  type        = string
  description = "Current environment"
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "Region of the resources"
  default     = "us-east-1"
}

variable "vpc_id" {
  type        = string
  description = "The default VPC ID"
  default     = "vpc-09a618deab83667b2"
}

variable "ecs_fargate_application_cpu" {
  type        = string
  description = "CPU units"
  default     = "256"
}

variable "ecs_fargate_application_mem" {
  type        = string
  description = "Memory value"
  default     = "512"
}

variable "ecs_application_count" {
  type        = number
  description = "Container count of the application"
  default     = 2
}
