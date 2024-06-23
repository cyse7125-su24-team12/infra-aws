provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster_data.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_data.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
  }
}

# resource "helm_release" "test_release" {
#     name       = "test-release"
#     repository = "https://charts.bitnami.com/bitnami"
#     chart      = "nginx"
#     depends_on = [kubernetes_namespace.namespace1, kubernetes_namespace.namespace2, kubernetes_namespace.namespace3]
#     namespace  = "default"
# }
