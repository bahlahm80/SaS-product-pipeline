# ALB is created by the AWS Load Balancer Controller when an Ingress appears.
# Its IAM policy lives in iam.tf — referenced here as:
#   aws_iam_policy.alb_controller.arn
#
# Next step: Helm release for the controller + IRSA role attachment
# using that policy ARN.
