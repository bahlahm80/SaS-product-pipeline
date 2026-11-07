terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "sas-terraform-state-bucket"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sas-terraform-locks"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "production"
      ManagedBy   = "Terraform"
    }
  }
}

module "sas" {
    source = "../../"

    environment = "production"
    aws_region  = "us-east-1"
    vpc_cidr    = "10.0.0.0/16"
    # ALB DNS/zone are outputs of the Load Balancer Controller and is not known at the first plan time.  Empty string for now.
    # Fill them after the first ingress creates the ALB
    alb_dns_name = ""
    alb_zone_id  = ""
    node_instance_types     = ["t3.large"]
    node_min_size           = 3
    node_max_size           = 10
    node_desired_size       = 3

    image_tag               = "v1.0.0"
    customers               = [""]
}

output "vpc_id" {
  value = module.sas.vpc_id
}

output "eks_cluster_endpoint" {
  value = module.sas.eks_cluster_endpoint
}

output "ecr_repository_url" {
  value = module.sas.ecr_repository_url
}