module "vpc" {
  source     = "./modules/network" # or terraform-aws-modules/vpc/aws
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  aws_region  = var.aws_region
}

module "eks" {
  source      = "./modules/eks"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets
}

module "ecr" {
  source      = "./modules/ecr"
  environment = var.environment
}