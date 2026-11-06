# main.tf
module "infrastructure" {
  source = "./resources"

  environment = var.environment
  aws_region  = var.aws_region
  vpc_cidr    = var.vpc_cidr
  alb_dns_name = var.alb_dns_name
  alb_zone_id  = var.alb_zone_id
}