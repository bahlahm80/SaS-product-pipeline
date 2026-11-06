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

resource "kubernetes_config_map" "site" {
    metadata {
        name        = "customer-${var.customer_slug}-site"
        namespace   = kubernetes_namespace_v1.this.metadata[0].name
    }
    data = {
        company_name    = var.company_name
        motto           = var.motto
    }
}

resource "kubernetes_deployment" "web" {
    metadata {
        name        = "customer-${var.customer_slug}-web"
        namespace   = kubernetes_namespace_v1.this.metadata[0].name
    }
    spec {
        replicas = var.replicas
        selector {
            match_labels = { app = "customer-${var.customer_slug}-web" }
        }
        template {
            metadata {
                labels = { app = "customer-${var.customer_slug}-web" }
            }
            spec {
                container {
                    name    = "nginx"
                    image   = "nginx:1.25"
                    port { container_port = 80 }
                    resources {
                        requests    = { cpu = "100m", memory = "128Mi" }
                        limits      = { cpu = "500m", memory = "256Mi" }
                    }
                }
                container {
                    name    = "backend"
                    image   = "sas-product:${var.image_tag}"
                    port { container_port = 8080 }
                    resources {
                        requests    = { cpu = "100m", memory = "128Mi" }
                        limits      = { cpu = "500m", memory = "256Mi" }
                    }
                    env {
                        name    = "COMPANY_NAME"
                        value_from {
                            config_map_key_ref {
                                name    = kubernetes_config_map.site.metadata[0].name
                                key     = "company_name"
                            }
                        }
                    }
                    env {
                        name    = "MOTTO"
                        value_from {
                            config_map_key_ref {
                                name    = kubernetes_config_map.site.metadata[0].name
                                key     = "motto"
                            }
                        }
                    }
                    env {
                        name    = "API_KEY"
                        value_from {
                            secret_key_ref {
                                name    = "customer-${var.customer_slug}-secrets"
                                key     = "api_key"
                            }
                        }
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "web" {
    metadata {
        name        = "customer-${var.customer_slug}-web"
        namespace   = kubernetes_namespace_v1.this.metadata[0].name
    }
    spec {
        selector = { app = "customer-${var.customer_slug}-web" }
        port {
            port        = 80
            target_port = 80
        }
    }
}

resource "kubernetes_ingress_v1" "web" {
    metadata {
        name        = "customer-${var.customer_slug}-web"
        namespace   = kubernetes_namespace_v1.this.metadata[0].name
    }
    spec {
        rule {
            host = var.host
            http {
                path {
                    path        = "/"
                    path_type   = "Prefix"
                    backend {
                        service {
                            name    = kubernetes_service.web.metadata[0].name
                            port { number = 80 }
                        }
                    }
                }
            }
        }
    }
}

# HPA (Objective 4): per-customer
resource "kubernetes_horizontal_pod_autoscaler_v2" "web" {
    metadata {
        name            = "customer-${var.customer_slug}-web"
        namespace       = kubernetes_namespace_v1.this.metadata[0].name
    }
    spec {
        scale_target_ref {
            api_version = "apps/v1"
            kind        = "Deployment"
            name        = kubernetes_deployment.web.metadata[0].name
        }
        min_replicas    = var.min_replicas
        max_replicas    = var.max_replicas
        metric {
            type = "Resource"
            resource {
                name = "cpu"
                target {
                    type                = "Utilization"
                    average_utilization = 70
                }
            }
        }
    }
}