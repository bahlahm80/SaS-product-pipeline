resource "aws_route53_zone" "main" {
  name = var.environment == "production" ? "sas-product.com" : "${var.environment}.sas-product.internal"
}

# Wildcard record to capture all tenant subdomains (*.sas-product.com)
# Pointing to the AWS Load Balancer Controller ingress endpoint
resource "aws_route53_record" "wildcard_tenant" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "*.${aws_route53_zone.main.name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name # Passed from ALB/Ingress output
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}