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

variable "node_instance_types" {
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_min_size" {
  type        = number
  default     = 1
}

variable "node_max_size" {
  type        = number
  default     = 3
}

variable "node_desired_size" {
  type        = number
  default     = 2
}

variable "customers" {
  description = "Customer slugs. One namespace + ResourceQuota per slug. Adding a customer = adding one slug here. Company name, motto, host, and image tag are app data — they go to Helm, not Terraform."
  type        = set(string)
  default     = []
}

variable "image_tag" {
  description = "Promoted, prod-approved image tag. Must be a valid version number e.g v1.0.0"
  type        = string
  default     = "v1.0.0"
}