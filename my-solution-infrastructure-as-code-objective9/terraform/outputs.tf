output "vpc_id" {
  value = module.infrastructure.vpc_id
}

output "eks_cluster_endpoint" {
  value = module.infrastructure.eks_cluster_endpoint
}

output "ecr_repository_url" {
  value = module.infrastructure.ecr_repository_url
}

output "customer_urls" {
  description = "One URL per customer, from the customer module."
  value = { for k, m in module.customer : k => m.url}
}