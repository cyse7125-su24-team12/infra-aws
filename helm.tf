provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster_data.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_data.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
  }
  alias = "helm-eks"
}

resource "helm_release" "kubernetes-autoscaler" {
  name                = "kubernetes-autoscaler"
  provider            = helm.helm-eks
  depends_on          = [aws_iam_role.eks_autoscaler_role, kubernetes_namespace.namespace_autoscaler, module.eks, kubernetes_secret.dockerhub_secret]
  repository          = var.github_chart_url
  chart               = "../helm-eks-autoscaler"
  repository_username = var.github_username
  repository_password = var.github_pat
  namespace           = var.namespace_autoscaler
  set {
    name  = "autoDiscovery.clusterName"
    value = var.kubernetes_autoscaler.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.kubernetes_autoscaler.aws_region
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.eks_autoscaler_role.arn
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = var.kubernetes_autoscaler.service_account_name
  }

  set {
    name  = "image.repository"
    value = var.autoscaler_config.image.repository
  }
  set {
    name  = "image.tag"
    value = var.autoscaler_config.image.tag
  }

  set {
    name  = "image.pullSecrets[0]"
    value = kubernetes_secret.dockerhub_secret.metadata[0].name
  }
}

resource "helm_release" "postgresql-ha-release" {
  name       = "postgresql-ha-release"
  repository = "https://charts.bitnami.com/bitnami"
  provider   = helm.helm-eks
  chart      = "postgresql-ha"
  depends_on = [kubernetes_namespace.namespace1, kubernetes_namespace.namespace2, kubernetes_namespace.namespace3]
  namespace  = var.postgres_ha.namespace
  values = [
    "${file("manifests/postgres-values.yaml")}"
  ]
}

resource "helm_release" "kafka" {
  name       = "kafka"
  repository = "https://charts.bitnami.com/bitnami"
  provider   = helm.helm-eks
  chart      = "kafka"
  depends_on = [kubernetes_namespace.namespace1, kubernetes_namespace.namespace2, kubernetes_namespace.namespace3]
  namespace  = var.kafka_config.namespace
  values = [
    "${file("manifests/kafka-values.yaml")}"
  ]
}
