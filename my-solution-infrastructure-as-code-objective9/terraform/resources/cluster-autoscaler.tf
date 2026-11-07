# Cluster Autoscaler - ServiceAccount + Helm Chart.
# Installed once per cluster, in kube-system, not once per customer. 
# WE need to scale nodes as HPA scales pods and if there is no node with room, the pods won't scale and get stuck

resource "kubernetes_service_account_v1" "cluster_autoscaler" {
  metadata {
    name        = "cluster-autoscaler"
    namespace   = "kube-system"
    annotations  = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  name          = "cluster-autoscaler"
  repository    = "https://kubernetes.github.io/autoscaler"
  chart         = "cluster-autoscaler"
  version       = "9.37.0"
  namespace     = "kube-system"

  set {
    name        = "rbac.serviceAccount.create"
    value      = "false"
  }
  set {
    name        = "rbac.serviceAccount.name"
    value      = "cluster-autoscaler"
  }

  set {
    name        = "autoDiscovery.clusterName"
    value      = module.eks.cluster_name
  }

  set {
    name        = "awsRegion"
    value      = var.aws_region
  }

  set {
    name  = "extraArgs.scale-down-unneeded-time"
    value = "10m"
  }

  depends_on = [
    kubernetes_service_account_v1.cluster_autoscaler,
  ]
}