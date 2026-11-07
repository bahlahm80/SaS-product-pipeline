# GitHub OIDC Provider for Secure Authentication
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # Standard GitHub OIDC thumbprint
}

# IAM Role assumed by GitHub Actions workflows dynamically per region/account
resource "aws_iam_role" "github_actions" {
  name = "GitHubActions-${var.environment}Role-${var.aws_region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:bahlahm80/SaS-product-pipeline"
          }
        }
      }
    ]
  })
}

# Policy granting ECR push/pull and EKS cluster management permissions
resource "aws_iam_role_policy" "github_actions_deployment" {
  name = "GitHubActionsDeploymentPolicy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}

# ALB Controller IAM policy — all IAM lives here
data "aws_iam_policy_document" "alb_controller" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "alb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy-${var.environment}"
  description = "IAM policy required for the Kubernetes AWS Load Balancer Controller"
  path        = "/"
  policy      = data.aws_iam_policy_document.alb_controller.json
}

data "aws_iam_policy_document" "cluster_autoscaler_assume_role" {
    statement {
      effect = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type  = "Federated"
        identifiers = [module.eks.oidc_provider_arn]
      }

      condition {
        test = "StringEquals"
        variable = "${module.eks.oidc_provider}:sub"
        values = ["system:serviceaccount:kube-system:cluster-autoscaler"]
      }
    }
}

resource "aws_iam_role" "cluster_autoscaler" {
  name = "cluster-autoscaler-${var.environment}Role-${var.aws_region}"

  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role.json
  tags = {
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVolumes",
      "eks:DescribeNodegroup",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "cluster-autoscaler-${var.environment}"
  description = "IAM policy required for the EKS cluster autoscaling"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role            = aws_iam_role.cluster_autoscaler.name
  policy_arn      = aws_iam_policy.cluster_autoscaler.arn
}