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
  namespace  = var.postgres_ha.namespace
  # values = [
  #   "${file("values.yaml")}"
  # ]

  set {
    name  = "fullnameOverride"
    value = var.postgres_ha.fullnameOverride
  }

  set {
    name = "service.type"
    # value = "LoadBalancer"
    value = var.postgres_ha.service_type
  }

  set {
    name = "persistance.storageClass"
    # value = "ebc-sc"
    value = var.postgres_ha.persistance_storageClass
  }

  set {
    name = "persistence.size"
    # value = "4Gi"
    value = var.postgres_ha.persistence_size
  }

  set {
    name = "postgresql.database"
    # value = "cve"
    value = var.postgres_ha.postgresql_database
  }

  set {
    name = "postgresql.username"
    # value = "cve_user"
    value = var.postgres_ha.postgresql_username
  }

  set {
    name = "postgresql.password"
    # value = "cve123"
    value = var.postgres_ha.postgresql_password
  }

  set {
    name = "postgresql.repmgrUsername"
    # value = "repmgr"
    value = var.postgres_ha.postgresql_repmgrUsername
  }

  set {
    name = "postgresql.repmgrPassword"
    # value = "repmgr123"
    value = var.postgres_ha.postgresql_repmgrPassword
  }

  set {
    name = "pgpool.adminPassword"
    # value = "admin123"
    value = var.postgres_ha.pgpool_adminPassword
  }


  set {
    name = "pgpool.adminUsername"
    # value = "pgadmin"
    value = var.postgres_ha.pgpool_adminUsername
  }

}

resource "helm_release" "kafka" {
  name       = "kafka"
  repository = "https://charts.bitnami.com/bitnami"
  provider   = helm.helm-eks
  chart      = "kafka"
  depends_on = [kubernetes_namespace.namespace1, kubernetes_namespace.namespace2, kubernetes_namespace.namespace3]
  namespace  = var.kafka_config.namespace

  set {
    name  = "provisioning.enabled"
    value = var.kafka_config.provisionEnabled
  }
  set {
    name  = "provisioning.topics[0].name"
    value = var.kafka_config.topicName
  }
  set {
    name = "provisioning.topics[0].partitions"
    # value = "3"
    value = var.kafka_config.topicPartitions
  }
  set {
    name = "provisioning.topics[0].replicationFactor"
    # value = "3"
    value = var.kafka_config.topicPartitions
  }
}
