variable "environment" {
  type        = string
  description = "Environment name (dev, staging, production)"
}

variable "aws_region" {
  type        = string
  description = "Target AWS Region (e.g. us-east-1, eusc-de-east-1)"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "alb_dns_name" {
  type        = string
  description = "DNS name of the ALB created by the AWS Load Balancer Controller"
}

variable "alb_zone_id" {
  type        = string
  description = "Hosted zone ID of the ALB created by the AWS Load Balancer Controller"
}
