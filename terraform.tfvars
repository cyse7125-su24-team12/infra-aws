cluster_eks = {
  cluster_name                    = "eks-cluster-tf"
  cluster_version                 = "1.29"
  create_iam_role                 = false
  cluster_enabled_log_types       = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cluster_encryption_policy_name  = "eks-cluster-tf-encryption-policy"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent           = true
      enable_network_policy = "true"
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
  eks_managed_node_groups = {
    worker_nodes = {
      desired_size    = 2
      max_size        = 8 # 6
      min_size        = 1
      create_iam_role = false
      # capacity_type   = "ON_DEMAND"
      capacity_type  = "SPOT"
      ami_type       = "AL2_x86_64"
      instance_types = ["c3.large"]
      # instance_types = ["t2.medium"]
      update_config = {
        max_unavailable = 1
      }
      labels = {
        nodegroup-name = "worker"
      }
    }
  }
  cluster_ip_family                       = "ipv4"
  enable_cluster_create_admin_permissions = true
  authentication_mode                     = "API_AND_CONFIG_MAP"
  node_security_group_additional_rules = {
    ingress_15017 = {
      description                   = "Cluster API - Istio Webhook namespace.sidecar-injector.istio.io"
      protocol                      = "TCP"
      from_port                     = 15017
      to_port                       = 15017
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ingress_15012 = {
      description                   = "Cluster API to nodes ports/protocols"
      protocol                      = "TCP"
      from_port                     = 15012
      to_port                       = 15012
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
}


security_group = {
  name        = "eks-cluster-sg"
  description = "EKS Cluster Security Group"
}

sg_ingress_rule = {
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

sg_egress_rule = {
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

ebs_csi_irsa_config = {
  attach_ebs_csi_policy = true
  role_policy_arns = {
    "AmazonEKS_CSI_Driver" = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
  role_name = "ebs-csi-irsa-role"
  oidc_providers = {
    example = {
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

key_for_ebs_volume = {
  description             = "Symmetric KMS key for EBS volume"
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 20
  policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "Enable IAM User Permissions"
        Effect   = "Allow"
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Key Administrators"
        Effect = "Allow"
        Action = [
          "kms:Update*",
          "kms:UntagResource",
          "kms:TagResource",
          "kms:ScheduleKeyDeletion",
          "kms:Revoke*",
          "kms:ReplicateKey",
          "kms:Put*",
          "kms:List*",
          "kms:ImportKeyMaterial",
          "kms:Get*",
          "kms:Enable*",
          "kms:Disable*",
          "kms:Describe*",
          "kms:Delete*",
          "kms:Create*",
          "kms:CancelKeyDeletion"

        ]
        Resource = "*"
      },
      {
        Sid    = "KeyUsage"
        Effect = "Allow"
        Action = [
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:DescribeKey",
          "kms:Decrypt",
          "kms:CreateGrant",
        ]
        Resource = "*"
      }
    ]
  }
}


aws_vpc = {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "aws_vpc"
  }
}

aws_public_subnet1 = {
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "aws_public_subnet1"
  }
  map_public_ip_on_launch = true
}

aws_public_subnet2 = {
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "aws_public_subnet2"
  }
  map_public_ip_on_launch = true
}

aws_public_subnet3 = {
  cidr_block        = "10.1.3.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "aws_public_subnet3"
  }
  map_public_ip_on_launch = true
}

aws_internet_gateway = {
  tags = {
    Name = "aws_internet_gateway"
  }
}

aws_route_table_public_subnets = {
  tags = {
    Name = "aws_route_table_public_subnets"
  }
  route = {
    cidr_block = "0.0.0.0/0"
  }
}

aws_private_subnet1 = {
  availability_zone = "us-east-1a"
  cidr_block        = "10.1.4.0/24"
  tags = {
    Name = "aws_private_subnet1"
  }
}

aws_route_table_private_subnet1 = {
  tags = {
    Name = "aws_route_table_private_subnet1"
  }
  route = {
    cidr_block = "0.0.0.0/0"
  }
}

aws_nat_eip_private_subnet1 = {
  tags = {
    Name = "aws_eip_private_subnet1"
  }
  domain = "vpc"
}

aws_nat_private_subnet1 = {
  tags = {
    Name = "aws_nat_private_subnet1"
  }
}


aws_private_subnet2 = {
  availability_zone = "us-east-1b"
  cidr_block        = "10.1.5.0/24"
  tags = {
    Name = "aws_private_subnet2"
  }
}

aws_nat_eip_private_subnet2 = {
  tags = {
    Name = "aws_eip_private_subnet2"
  }
  domain = "vpc"
}

aws_nat_private_subnet2 = {
  tags = {
    Name = "aws_nat_private_subnet2"
  }
}

aws_route_table_private_subnet2 = {
  tags = {
    Name = "aws_route_table_private_subnet2"
  }
  route = {
    cidr_block = "0.0.0.0/0"
  }
}

aws_private_subnet3 = {
  availability_zone = "us-east-1c"
  cidr_block        = "10.1.6.0/24"
  tags = {
    Name = "aws_private_subnet3"
  }
}

aws_nat_eip_private_subnet3 = {
  tags = {
    Name = "aws_eip_private_subnet3"
  }
  domain = "vpc"
}

aws_nat_private_subnet3 = {
  tags = {
    Name = "aws_nat_private_subnet3"
  }
}


aws_route_table_private_subnet3 = {
  tags = {
    Name = "aws_route_table_private_subnet3"
  }
  route = {
    cidr_block = "0.0.0.0/0"
  }
}

eks_cluster_role = {
  name = "eks_cluster_role_tf"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  ]
}

eks_node_role = {
  name = "eks_node_role_tf"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

aws_iam_policy_document_eks = {
  statement = {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals = {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

aws_iam_policy_document_eks_node = {
  statement = {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "eks.amazonaws.com"]
    }
  }
}

postgres_ha = {
  namespace                 = "namespace3"
  fullnameOverride          = "cve-webapp-db"
  service_type              = "LoadBalancer"
  persistance_storageClass  = "ebc-sc"
  persistence_size          = "4Gi"
  postgresql_database       = "cve"
  postgresql_username       = "cve_user"
  postgresql_password       = "<placeholder>"
  postgresql_repmgrUsername = "repmgr"
  postgresql_repmgrPassword = "<placeholder>"
  pgpool_adminUsername      = "pgadmin"
  pgpool_adminPassword      = "<placeholder>"
}


kafka_config = {
  namespace              = "namespace2"
  provisionEnabled       = true
  topicName              = "cve"
  topicPartitions        = 3
  topicReplicationFactor = 2
}

namespace1             = "namespace1"
namespace2             = "namespace2"
namespace3             = "namespace3"
namespace_autoscaler   = "namespace-autoscaler"
namespace_istio_system = "istio-system"

sc_config = {
  name                = "ebs-sc"
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
  parameters = {
    type      = "gp2"
    encrypted = "true"
    # kmsKeyId  = aws_kms_key.key_for_ebs_volume.arn
  }
}

kubernetes_autoscaler = {
  cluster_name         = "eks-cluster-tf"
  aws_region           = "us-east-1"
  service_account_name = "cluster-autoscaler"
}


eks_autoscaler_policy_doc = {
  statement = {
    actions = [
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

eks_autoscaler_policy = {
  name        = "eks_autoscaler_policy"
  description = "EKS Autoscaler Policy"
}

github_pat      = "<github_pat>"
github_username = "shyam2520"

github_chart_url = "https://github.com/cyse7125-su24-team12/helm-eks-autoscaler"

docker_hub_registry = "https://index.docker.io/v1/"
docker_hub_username = "bala699"
docker_hub_password = "<docker_pat>"
docker_hub_email    = "ubalasubramanian03@gmail.com"

autoscaler_config = {
  image = {
    repository = "bala699/cluster-autoscaler"
    tag        = "v1.30.0"
  }
  asset_url = "https://api.github.com/repos/cyse7125-su24-team12/helm-eks-autoscaler/releases/assets/180864536"
}

sa_cert_manager = "cert-manager-sa"
sa_external_dns = "external-dns-sa"

namespaces = {
  namespace1 = {
    name            = "namespace1"
    istio_injection = "enabled"
  },
  namespace3 = {
    name            = "namespace3"
    istio_injection = "enabled"
  },
  namespace2 = {
    name            = "namespace2"
    istio_injection = "enabled"
  }
  namespace_autoscaler = {
    name = "namespace-autoscaler"
  }
  cve_operator = {
    name            = "cve-operator"
    istio_injection = "enabled"
  }

  amazon_cloudwatch = {
    name = "amazon-cloudwatch"
  }

  namespace_istio = {
    name = "istio-system"
  }
  prometheus_graphana_ns = {
    name = "prometheus-graphana"
    # istio_injection = "enabled"
  }
  # kiali = {
  #   name = "kiali"
  #   istio_injection = "enabled"
  # }
}
