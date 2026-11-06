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
  type        = number,
  default     = 1
}

variable "node_max_size" {
  type        = number,
  default     = 3
}

variable "node_desired_size" {
  type        = number,
  default     = 2
}

variable "container_cpu_request" {
  type        = string,
  default     = "100m"
}

variable "container_memory_request" {
  type        = string,
  default     = "128Mi"
}

variable "container_cpu_limit" {
  type        = string,
  default     = "500m"
}

variable "container_memory_limit" {
  type        = string,
  default     = "256Mi"
}

variable "customers" {
  description = "One entry per customer.  Adding a customer = adding one entry here."
  type        = map(object({
    company_name  = string
    motto         = string
    host          = string
    image_tag     = optional(string)
    replicas      = optional(number, 2)
    min_replicas  = optional(number, 2)
    max_replicas  = optional(number, 5)
  }))
  default     = {}
}

variable "image_tag" {
  description = "Promoted, prod-approved image tag. Must be a valid version number e.g v1.0.0"
  type        = string
  default     = "v1.0.0"
}