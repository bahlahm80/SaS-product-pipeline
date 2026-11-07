# main.tf
module "infrastructure" {
  source = "./resources"

  environment           = var.environment
  aws_region            = var.aws_region
  vpc_cidr              = var.vpc_cidr
  alb_dns_name          = var.alb_dns_name
  alb_zone_id           = var.alb_zone_id
  node_instance_types   = var.node_instance_types
  node_min_size         = var.node_min_size
  node_max_size         = var.node_max_size
  node_desired_size     = var.node_desired_size
}

module "customer" {
  source   = "./modules/customer"
  for_each = var.customers

  customer_slug = each.value
}