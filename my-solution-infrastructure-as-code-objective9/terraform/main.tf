# main.tf
module "infrastructure" {
  source = "./resources"

  environment = var.environment
  aws_region  = var.aws_region
  vpc_cidr    = var.vpc_cidr
}