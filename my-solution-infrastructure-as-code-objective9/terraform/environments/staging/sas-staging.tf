terraform {
    required_version = ">= 1.6.0"

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }

    backend "s3" {
        bucket          = "sas-terraform-state-bucket"
        key             = "staging/terraform.tfstate"
        region          = "us-east-1"
        dynamodb_table  = "sas-terraform-locks"
    }
}

provider "aws" {
    region = "us-east-1"

    default_tags {
        tags = {
            Environment = "staging"
            ManagedBy   = "Terraform"
        }
    }
}

module "sas" {
    source = "../../"

    environment     = "staging"
    aws_region      = "us-east-1"
    vpc_cidr        = "10.0.0.0/16"
    # ALB DNS/zone are outputs of the Load Balancer Controller and is not known at the first plan time.  Empty string for now.
    # Fill them after the first ingress creates the ALB
    alb_dns_name    = ""
    alb_zone_id     = ""
}

output "vpc_id" {
    value = module.sas.vpc_id
}

output "ekc_cluster_endpoint" {
    value = module.sas.eks_cluster_endpoint
}

output "ecr_repository_url" {
    value = module.sas.ecr_repository_url
}