# resources/cloudwatch.tf

# 1. CloudWatch Log Group for EKS Control Plane Audit & Diagnostic Logs
resource "aws_cloudwatch_log_group" "eks_logs" {
  name              = "/aws/eks/sas-cluster-${var.environment}/cluster"
  retention_in_days = var.environment == "production" ? 30 : 7

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 2. Enable EKS Control Plane Logging via the EKS Module dependency or AWS provider
# (Note: The terraform-aws-modules/eks/aws module natively accepts cluster_enabled_log_types)