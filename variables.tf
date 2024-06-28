variable "cluster_eks" {
  type        = any
  description = "EKS Cluster Configuration"

}

variable "security_group" {
  type        = any
  description = "Security Group Configuration"
}

variable "sg_ingress_rule" {
  type        = any
  description = "Security Group Ingress Rule Configuration"
}

variable "sg_egress_rule" {
  type        = any
  description = "Security Group Egress Rule Configuration"
}

variable "ebs_csi_irsa_config" {
  type        = any
  description = "IRSA EBS Configuration"
}

variable "key_for_ebs_volume" {
  type        = any
  description = "KMS Key for EBS Volume"
}

variable "aws_vpc" {
  type        = any
  description = "VPC Configuration"
}

variable "aws_public_subnet1" {
  type        = any
  description = "Public Subnet 1 Configuration"
}

variable "aws_public_subnet2" {
  type        = any
  description = "Public Subnet 2 Configuration"
}

variable "aws_public_subnet3" {
  type        = any
  description = "Public Subnet 3 Configuration"
}

variable "aws_private_subnet1" {
  type        = any
  description = "Private Subnet 1 Configuration"
}


variable "aws_internet_gateway" {
  type        = any
  description = "Internet Gateway Configuration"
}

variable "aws_route_table_public_subnets" {
  type        = any
  description = "Route Table for Public Subnets Configuration"

}

variable "aws_nat_eip_private_subnet1" {
  type        = any
  description = "EIP for NAT Gateway Configuration"
}

variable "aws_nat_private_subnet1" {
  type        = any
  description = "NAT Gateway for Private Subnet 1 Configuration"
}

variable "aws_route_table_private_subnet1" {
  type        = any
  description = "Route Table for Private Subnet 1 Configuration"
}

variable "aws_private_subnet2" {
  type        = any
  description = "Private Subnet 2 Configuration"
}

variable "aws_nat_eip_private_subnet2" {
  type        = any
  description = "EIP for NAT Gateway Configuration"
}

variable "aws_nat_private_subnet2" {
  type        = any
  description = "NAT Gateway for Private Subnet 2 Configuration"
}

variable "aws_route_table_private_subnet2" {
  type        = any
  description = "Route Table for Private Subnet 2 Configuration"

}
variable "aws_private_subnet3" {
  type        = any
  description = "Private Subnet 3 Configuration"
}

variable "aws_nat_eip_private_subnet3" {
  type        = any
  description = "EIP for NAT Gateway Configuration"
}

variable "aws_nat_private_subnet3" {
  type        = any
  description = "NAT Gateway for Private Subnet 3 Configuration"
}

variable "aws_route_table_private_subnet3" {
  type        = any
  description = "Route Table for Private Subnet 3 Configuration"
}

variable "eks_cluster_role" {
  type        = any
  description = "EKS Cluster Role Configuration"

}

variable "eks_node_role" {
  type        = any
  description = "EKS Node Role Configuration"
}

variable "aws_iam_policy_document_eks" {
  type        = any
  description = "IAM Policy Document Configuration"

}

variable "aws_iam_policy_document_eks_node" {
  type        = any
  description = "IAM Policy Document Configuration"

}

variable "postgres_ha" {
  type        = any
  description = "Postgres HA Configuration"
}

variable "kafka_config" {
  type        = any
  description = "Kafka Configuration"
}

variable "namespace1" {
  type        = string
  description = "Namespace 1 Configuration"
}

variable "namespace2" {
  type        = string
  description = "Namespace 1 Configuration"
}

variable "namespace3" {
  type        = string
  description = "Namespace 1 Configuration"
}

variable "sc_config" {
  type        = any
  description = "Storage Class Configuration"
  
}
