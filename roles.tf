data "aws_iam_policy_document" "eks_cluster_assume_role_policy" {
  statement {
    actions = var.aws_iam_policy_document_eks["statement"]["actions"]
    effect  = var.aws_iam_policy_document_eks["statement"]["effect"]
    principals {
      type        = var.aws_iam_policy_document_eks["statement"]["principals"]["type"]
      identifiers = var.aws_iam_policy_document_eks["statement"]["principals"]["identifiers"]
    }
  }
}

data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  statement {
    actions = var.aws_iam_policy_document_eks_node["statement"]["actions"]
    effect  = var.aws_iam_policy_document_eks_node["statement"]["effect"]
    principals {
      type        = var.aws_iam_policy_document_eks_node["statement"]["principals"]["type"]
      identifiers = var.aws_iam_policy_document_eks_node["statement"]["principals"]["identifiers"]
    }
  }
}


resource "aws_iam_role" "eks_cluster_role" {
  name                = var.eks_cluster_role["name"]
  depends_on          = [data.aws_iam_policy_document.eks_cluster_assume_role_policy]
  managed_policy_arns = var.eks_cluster_role["managed_policy_arns"]
  assume_role_policy  = data.aws_iam_policy_document.eks_cluster_assume_role_policy.json
}

resource "aws_iam_role" "eks_node_role" {
  name                = var.eks_node_role["name"]
  depends_on          = [data.aws_iam_policy_document.eks_cluster_assume_role_policy]
  managed_policy_arns = var.eks_node_role["managed_policy_arns"]
  assume_role_policy  = data.aws_iam_policy_document.eks_node_assume_role_policy.json
}
