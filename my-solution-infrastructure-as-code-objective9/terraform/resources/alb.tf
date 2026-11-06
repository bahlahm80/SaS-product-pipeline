# IAM policy for AWS Load Balancer Controller running inside EKS
resource "aws_iam_policy" "alb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy-${var.environment}"
  description = "IAM policy required for the Kubernetes AWS Load Balancer Controller"
  path        = "/"
  policy      = file("${path.module}/policies/alb-controller-policy.json") # Standard AWS provided JSON policy
}