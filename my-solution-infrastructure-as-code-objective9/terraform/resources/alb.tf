# ALB is NOT created by Terraform — it is created by the AWS Load
# Balancer Controller when it sees an Ingress. Terraform only
# provides the IAM policy (iam.tf: aws_iam_policy.alb_controller)
# and the Route53 wildcard alias pointing at the ALB's DNS name.
# NOT BUILT: the controller install itself (helm_release +
# IRSA role attaching that policy) — same pattern as the
# Cluster Autoscaler, which IS built. Route53's alb_dns_name
# is empty until the first Ingress creates an ALB.
# I am leaving this file just because I used ALB for my Orchy project at Workday behind ECS.
