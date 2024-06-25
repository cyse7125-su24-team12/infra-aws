provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster_data.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_data.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
  }
  alias = "helm-eks"
}

resource "helm_release" "postgresql-ha-release" {
  name       = "postgresql-ha-release"
  repository = "https://charts.bitnami.com/bitnami"
  provider   = helm.helm-eks
  chart      = "postgresql-ha"
  depends_on = [kubernetes_namespace.namespace1, kubernetes_namespace.namespace2, kubernetes_namespace.namespace3]
  namespace  = "namespace3"
  set {
    name  = "fullnameOverride"
    value = "cve-webapp-processor"
  }

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "persistance.storageClass"
    value = "ebc-sc"
  }

  set{
    name = "persistence.size"
    value = "4Gi"
  }

  set{
    name = "postgresql.database"
    value = "cve"
  }

  set{
    name = "postgresql.username"
    value = "cve_user"
  }

  set{
    name = "postgresql.password"
    value = "cve123"
  }

  set{
    name = "postgresql.repmgrUsername"
    value = "repmgr"
  }

  set{
    name = "postgresql.repmgrPassword"
    value = "repmgr123"
  }

  set{
    name = "pgpool.adminPassword"
    value = "admin123"
  }


  set{
    name = "pgpool.adminUsername"
    value = "pgadmin"
  }

}
