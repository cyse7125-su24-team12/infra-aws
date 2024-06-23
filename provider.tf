terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~>2.0.2"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~>2.31.0"
    }

  }
}
