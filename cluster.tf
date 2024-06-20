module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.14.0"

  depends_on = [
    aws_iam_role.eks_cluster_role,
    aws_iam_role.eks_node_role,
    aws_subnet.aws_private_subnet1,
    aws_subnet.aws_private_subnet2,
    aws_subnet.aws_private_subnet3,
    aws_vpc.aws_vpc,
    # aws_kms_key.key_for_eks_cluster,
    aws_security_group.eks_cluster_sg,
  ]
  cluster_name                    = var.cluster_eks["cluster_name"]
  cluster_version                 = var.cluster_eks["cluster_version"]
  create_iam_role                 = var.cluster_eks["create_iam_role"]
  iam_role_arn                    = aws_iam_role.eks_cluster_role.arn
  cluster_enabled_log_types       = var.cluster_eks["cluster_enabled_log_types"]
  cluster_encryption_policy_name  = var.cluster_eks["cluster_encryption_policy_name"]
  cluster_endpoint_private_access = var.cluster_eks["cluster_endpoint_private_access"]
  cluster_endpoint_public_access  = var.cluster_eks["cluster_endpoint_public_access"]
  enable_irsa                     = var.cluster_eks["enable_irsa"]
  control_plane_subnet_ids = [
    aws_subnet.aws_private_subnet1.id,
    aws_subnet.aws_private_subnet2.id,
    aws_subnet.aws_private_subnet3.id
  ]
  cluster_addons = {
    coredns = {
      most_recent = var.cluster_eks["cluster_addons"]["coredns"]["most_recent"]
    }
    kube-proxy = {
      most_recent = var.cluster_eks["cluster_addons"]["kube-proxy"]["most_recent"]
    }
    vpc-cni = {
      most_recent = var.cluster_eks["cluster_addons"]["vpc-cni"]["most_recent"]
    }
    eks-pod-identity-agent = {
      most_recent = var.cluster_eks["cluster_addons"]["eks-pod-identity-agent"]["most_recent"]
    }
    aws-ebs-csi-driver = {
      most_recent              = var.cluster_eks["cluster_addons"]["aws-ebs-csi-driver"]["most_recent"]
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }
  # subents for node groups 
  subnet_ids = [
    aws_subnet.aws_private_subnet1.id,
    aws_subnet.aws_private_subnet2.id,
    aws_subnet.aws_private_subnet3.id
  ]
  eks_managed_node_groups = {
    worker_nodes = {
      desired_size    = var.cluster_eks["eks_managed_node_groups"]["worker_nodes"]["desired_size"]
      max_size        = var.cluster_eks["eks_managed_node_groups"]["worker_nodes"]["max_size"]
      min_size        = var.cluster_eks["eks_managed_node_groups"]["worker_nodes"]["min_size"]
      create_iam_role = var.cluster_eks["eks_managed_node_groups"]["worker_nodes"]["create_iam_role"]
      iam_role_arn    = aws_iam_role.eks_node_role.arn
      capacity_type   = var.cluster_eks["eks_managed_node_groups"]["worker_nodes"]["capacity_type"]
      ami_type        = var.cluster_eks["eks_managed_node_groups"]["worker_nodes"]["ami_type"]
      instance_types  = var.cluster_eks["eks_managed_node_groups"]["worker_nodes"]["instance_types"]
      update_config = {
        max_unavailable = var.cluster_eks["eks_managed_node_groups"]["worker_nodes"]["update_config"]["max_unavailable"]
      }
      # node_security_group_id = aws_security_group.eks_cluster_sg.id
    }
  }
  # create_kms_key = false
  # cluster_encryption_config = {
  #   provider_key_arn = aws_kms_key.key_for_eks_cluster.arn
  #   resources        = ["secrets"]
  # }
  cluster_security_group_id                = aws_security_group.eks_cluster_sg.id
  cluster_ip_family                        = var.cluster_eks["cluster_ip_family"]
  enable_cluster_creator_admin_permissions = var.cluster_eks["enable_cluster_create_admin_permissions"]
  authentication_mode                      = var.cluster_eks["authentication_mode"]
  vpc_id                                   = aws_vpc.aws_vpc.id
}
