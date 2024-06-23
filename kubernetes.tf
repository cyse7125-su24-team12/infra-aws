data "aws_eks_cluster" "cluster_data" {
    depends_on = [ module.eks ]

  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}


provider "kubernetes" {
    host                   = data.aws_eks_cluster.cluster_data.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_data.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
    # version                = "~> 1.11"  
}

resource "kubernetes_namespace" "namespace1" {
  metadata {
    name = "namepsace1"
  }
}

resource "kubernetes_namespace" "namespace2" {
    metadata {
        name = "namepsace2"
    }
}

resource "kubernetes_namespace" "namespace3" {
    metadata {
        name = "namepsace3"
    }
}
