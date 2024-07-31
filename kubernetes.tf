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
}

resource "kubernetes_namespace" "namespace1" {
  depends_on = [module.eks, module.ebs_csi_irsa_role]
  provider   = kubernetes.kubernetes-eks
  metadata {
    name = "namespace1"
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
