resource "kubernetes_namespace_v1" "this" {
    metadata {
        name    = "customer-${var.customer_slug}"
        labels  = { customer = var.customer_slug }
    }
}

resource "kubernetes_resource_quota_v1" "this" {
    metadata {
        name        = "customer-${var.customer_slug}-quota"
        namespace   = kubernetes_namespace_v1.this.metadata[0].name 
    }
    spec {
        hard = {
            "requests.cpu"      = "2"
            "requests.memory"   = "2Gi"
            "limits.cpu"        = "4"
            "limits.memory"     = "4Gi"
            "pods"              = "10"
        }
    }
}