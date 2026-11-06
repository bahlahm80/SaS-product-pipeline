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
  source                = "./modules/customer"
  for_each              = var.customers

  customer_slug         = each.key
  company_name          = each.value.company_name
  motto                 = each.value.motto
  host                  = each.value.host
  image_tag             = coalesce(each.value.image_tag, var.image_tag)
  replicas              = each.value.replicas
  min_replicas          = each.value.min_replicas
  max_replicas          = each.value.max_replicas
}