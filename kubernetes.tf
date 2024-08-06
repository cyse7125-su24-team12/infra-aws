data "aws_eks_cluster" "cluster_data" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name
}


provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_data.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  alias                  = "kubernetes-eks"
  # version                = "~> 1.11"  
  # insecure = true 
}

resource "kubernetes_namespace" "namespace1" {
  depends_on = [module.eks, module.ebs_csi_irsa_role]
  provider   = kubernetes.kubernetes-eks
  metadata {
    name = "namespace1"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "kubernetes_limit_range" "namespace1_limits" {
  depends_on = [kubernetes_namespace.namespace1]
  provider   = kubernetes.kubernetes-eks
  metadata {
    name      = "default-limits"
    namespace = kubernetes_namespace.namespace1.metadata[0].name
  }
  spec {
    limit {
      default = {
        cpu    = "1"
        memory = "512Mi"
      }
      default_request = {
        cpu    = "500m"
        memory = "256Mi"
      }
      type = "Container"
    }
  }
}

resource "kubernetes_namespace" "namespace2" {
  depends_on = [module.eks, module.ebs_csi_irsa_role]
  provider   = kubernetes.kubernetes-eks

  metadata {
    name = "namespace2"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "kubernetes_limit_range" "namespace2_limits" {
  depends_on = [kubernetes_namespace.namespace2]
  provider   = kubernetes.kubernetes-eks
  metadata {
    name      = "default-limits"
    namespace = kubernetes_namespace.namespace2.metadata[0].name
  }
  spec {
    limit {
      default = {
        cpu    = "1"
        memory = "512Mi"
      }
      default_request = {
        cpu    = "500m"
        memory = "256Mi"
      }
      type = "Container"
    }
  }
}

resource "kubernetes_namespace" "namespace3" {
  depends_on = [module.eks, module.ebs_csi_irsa_role]
  provider   = kubernetes.kubernetes-eks

  metadata {
    name = "namespace3"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "kubernetes_limit_range" "namespace3_limits" {
  depends_on = [kubernetes_namespace.namespace3]
  provider   = kubernetes.kubernetes-eks
  metadata {
    name      = "default-limits"
    namespace = kubernetes_namespace.namespace3.metadata[0].name
  }
  spec {
    limit {
      default = {
        cpu    = "1"
        memory = "512Mi"
      }
      default_request = {
        cpu    = "500m"
        memory = "256Mi"
      }
      type = "Container"
    }
  }
}

resource "kubernetes_storage_class" "pvc_sc" {
  depends_on = [aws_kms_key.key_for_ebs_volume, module.eks]
  provider   = kubernetes.kubernetes-eks
  metadata {
    name = var.sc_config.name
  }
  storage_provisioner = var.sc_config.storage_provisioner
  reclaim_policy      = var.sc_config.reclaim_policy
  volume_binding_mode = var.sc_config.volume_binding_mode
  parameters = {
    type      = var.sc_config.parameters.type
    encrypted = var.sc_config.parameters.encrypted
    kmsKeyId  = aws_kms_key.key_for_ebs_volume.arn
  }
}

resource "kubernetes_namespace" "namespace_autoscaler" {
  depends_on = [module.eks, module.ebs_csi_irsa_role]
  provider   = kubernetes.kubernetes-eks

  metadata {
    name = var.namespace_autoscaler
  }
}

resource "kubernetes_limit_range" "namespace_autoscaler_limits" {
  depends_on = [kubernetes_namespace.namespace_autoscaler]
  provider   = kubernetes.kubernetes-eks
  metadata {
    name      = "default-limits"
    namespace = kubernetes_namespace.namespace_autoscaler.metadata[0].name
  }
  spec {
    limit {
      default = {
        cpu    = "1"
        memory = "512Mi"
      }
      default_request = {
        cpu    = "500m"
        memory = "256Mi"
      }
      type = "Container"
    }
  }
}

resource "kubernetes_secret" "dockerhub_secret" {
  depends_on = [module.eks]
  provider   = kubernetes.kubernetes-eks
  metadata {
    name      = "dockerhub-secret"
    namespace = var.namespace_autoscaler
  }

  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.docker_hub_registry}" = {
          "username" = var.docker_hub_username
          "password" = var.docker_hub_password
          "email"    = var.docker_hub_email
          "auth"     = base64encode("${var.docker_hub_username}:${var.docker_hub_password}")
        }
      }
    })
  }
}

resource "kubernetes_namespace" "cve_operator" {
  depends_on = [module.eks, module.ebs_csi_irsa_role]
  provider   = kubernetes.kubernetes-eks

  metadata {
    name = "cve-operator"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "kubernetes_secret" "dockerhub_secret_cve_operator" {
  depends_on = [module.eks]
  provider   = kubernetes.kubernetes-eks
  metadata {
    name      = "docker-secret"
    namespace = kubernetes_namespace.cve_operator.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.docker_hub_registry}" = {
          "username" = var.docker_hub_username
          "password" = var.docker_hub_password
          "email"    = var.docker_hub_email
          "auth"     = base64encode("${var.docker_hub_username}:${var.docker_hub_password}")
        }
      }
    })
  }
}


resource "kubernetes_limit_range" "namespace_cve_operator_limits" {
  depends_on = [kubernetes_namespace.cve_operator]
  provider   = kubernetes.kubernetes-eks
  metadata {
    name      = "default-limits"
    namespace = kubernetes_namespace.cve_operator.metadata[0].name
  }
  spec {
    limit {
      default = {
        cpu    = "1"
        memory = "512Mi"
      }
      default_request = {
        cpu    = "500m"
        memory = "256Mi"
      }
      type = "Container"
    }
  }
}

resource "kubernetes_namespace" "amazon_cloudwatch" {
  depends_on = [module.eks, module.ebs_csi_irsa_role]
  provider   = kubernetes.kubernetes-eks

  metadata {
    name = "amazon-cloudwatch"
  }
}

resource "kubernetes_limit_range" "namespace_amazon_cloudwatch_limits" {
  depends_on = [kubernetes_namespace.amazon_cloudwatch]
  provider   = kubernetes.kubernetes-eks
  metadata {
    name      = "default-limits"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
  }
  spec {
    limit {
      default = {
        cpu    = "1"
        memory = "512Mi"
      }
      default_request = {
        cpu    = "500m"
        memory = "256Mi"
      }
      type = "Container"
    }
  }
}
resource "kubernetes_namespace" "namespace_istio" {
  depends_on = [module.eks, module.ebs_csi_irsa_role]
  provider   = kubernetes.kubernetes-eks

  metadata {
    name = "istio-system"
  }

}

resource "kubernetes_namespace" "prometheus_graphana_ns" {
  depends_on = [module.eks, module.ebs_csi_irsa_role]
  provider   = kubernetes.kubernetes-eks

  metadata {
    name = "prometheus-graphana"
  }
}

resource "kubernetes_namespace" "cert_manager" {
  depends_on = [module.eks, module.ebs_csi_irsa_role]
  provider   = kubernetes.kubernetes-eks
  metadata {
    name = "cert-manager"
  }
}

# resource "kubernetes_manifest" "istio_ingress_gateway" {
#   depends_on = [module.eks]
#   provider   = kubernetes.kubernetes-eks
#   # namespace  = kubernetes_namespace.prometheus_graphana_ns.metadata[0].name
#   manifest = yamldecode(file("${path.module}/manifests/ingress-gateway.yaml"))
# }

# resource "kubernetes_manifest" "virtual_service_grafana" {
#   depends_on = [module.eks]
#   provider   = kubernetes.kubernetes-eks
#   manifest   = yamldecode(file("${path.module}/manifests/virtual-service-grafana.yaml"))
# }

# resource "kubernetes_manifest" "certificate_issuer" {
#   depends_on = [module.eks, helm_release.cert_manager]
#   provider   = kubernetes.kubernetes-eks
#   manifest   = yamldecode(file("${path.module}/manifests/certificate-issuer.yaml"))
# }


# resource "kubernetes_manifest" "certificate_values" {
#   depends_on = [module.eks, helm_release.cert_manager, kubernetes_manifest.certificate_issuer]
#   provider   = kubernetes.kubernetes-eks
#   manifest   = yamldecode(file("${path.module}/manifests/certificate-values.yaml"))
# }

# resource "kubernetes_manifest" "cert_mgr_role" {
#   depends_on = [module.eks, helm_release.cert_manager]
#   provider   = kubernetes.kubernetes-eks
#   manifest   = yamldecode(file("${path.module}/manifests/cert-mgr-role.yaml"))
# }

# resource "kubernetes_manifest" "cert_mgr_rolebinding" {
#   depends_on = [module.eks, helm_release.cert_manager, kubernetes_manifest.cert_mgr_role]
#   provider   = kubernetes.kubernetes-eks
#   manifest   = yamldecode(file("${path.module}/manifests/cert-mgr-rolebinding.yaml"))
# }

data "kubernetes_service" "istio_gateway_service_data" {
  depends_on = [helm_release.istio_gateway, module.eks, ]
  provider   = kubernetes.kubernetes-eks
  metadata {
    name      = "istio-gateway" # same name as what you give the helm chart for gateway
    namespace = kubernetes_namespace.namespace_istio.metadata[0].name
  }
}

output "kubernetes_service_hostname" {
  value = data.kubernetes_service.istio_gateway_service_data.status.0.load_balancer.0.ingress.0.hostname
}



# resource "kubernetes_network_policy" "network_policy" {
#   provider = kubernetes.kubernetes-eks
#   for_each = {
#     for ns, ns_data in var.namespaces : ns => ns_data
#     if lookup(ns_data, "istio_injection", "disabled") == "enabled"
#   }
#   metadata {
#     name      = "network-policy"
#     namespace = each.value.name
#   }
#   spec {
#     pod_selector {
#       match_expressions {
#         key      = "sidecar.istio.io/inject"
#         operator = "NotIn"
#         values   = ["false"]
#       }
#     }
#     ingress {
#       from {
#         namespace_selector {}
#       }
#       from {
#         pod_selector {
#           match_expressions {
#             key      = "app.kubernetes.io/name"
#             operator = "In"
#             values   = ["prometheus", "istiod"]
#           }
#         }
#       }
#       ports {
#         protocol = "TCP"
#         port     = "15090"
#       }
#       ports {
#         protocol = "TCP"
#         port     = "15020"
#       }
#     }

#     egress {}
#     policy_types = ["Ingress", "Egress"]
#   }

#   depends_on = [module.eks]
# }
