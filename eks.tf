locals {
  eks_cluster_name = "${var.eks_cluster_prefix}-${var.environment}"
}

variable "addon_version_kube_proxy" {
  description = "EKS Addon kube proxy"
  type        = string
  default     = "1.21.2-eksbuild.2"
}

variable "addon_version_coredns" {
  description = "EKS Addon coredns"
  type        = string
  default     = "1.8.3"
}

variable "addon_version_vpc_cni" {
  description = "EKS Addon vpccni"
  type        = string
  default     = "v1.9.0-eksbuild.1"
}

variable "eks_cluster_prefix" {
  description = "EKS Cluster prefix"
  type        = string
  default     = "sandbox"
}

variable "worker_instance_class" {
  description = "EKS Worker aws instance family class"
  type        = string
  default     = "t3a.medium"
}

variable "node_groups" {
  description = "EKS nodegroups"
}

variable "cluster_version" {
  description = "The version of k8s cluster"
  type        = string
}

variable "control_plane_logs" {
  description = "List of the control plane logs to enable"
  type        = list(string)
}

# additional_tags   = list(string)


##########################
# Additional eks subnets #
##########################

variable "private_eks_subnets" {
  description = "Public_Subnet IP Ranges"
  type        = list(string)
  default     = ["10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]
}

resource "aws_subnet" "eks_subnets" {
  count             = length(var.private_eks_subnets)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.private_eks_subnets[count.index]

  tags = {
    "Name" = "eks-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "eks_subnets" {
  count          = length(var.private_eks_subnets)
  subnet_id      = aws_subnet.eks_subnets[count.index].id
  route_table_id = module.vpc.private_route_table_ids[count.index]
}

data "aws_eks_cluster" "sandbox" {
  name = module.eks_sandbox.cluster_id
}

data "aws_eks_cluster_auth" "sandbox" {
  name = module.eks_sandbox.cluster_id
}


data "aws_caller_identity" "current" {}

module "eks_sandbox" {
  source           = "terraform-aws-modules/eks/aws"
  version          = "17.1.0"
  cluster_name     = local.eks_cluster_name
  cluster_version  = var.cluster_version # k8s version
  write_kubeconfig = false
  vpc_id           = module.vpc.vpc_id
  subnets          = module.vpc.private_subnets

  # In case of removing logging, at this moment it needs to be deleted from
  # aws manually. More info https://github.com/hashicorp/terraform/issues/23309
  cluster_enabled_log_types = var.control_plane_logs

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }

  node_groups_defaults = {
    # Options are described at:
    # https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/12.2.0/submodules/node_groups
    disk_size = 100
    # If key_name is specified: THE REMOTE ACCESS WILL BE OPENED TO THE WORLD
    # Therefore SG is needed to restrict the access
    # source: https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/node_groups
    # A new security group will be created and that SG will allow SSH by the security group which is specified here.

    subnets = aws_subnet.eks_subnets.*.id
  }

  node_groups = var.node_groups

  /*
  Initially, only the creator of the Amazon EKS cluster has system:masters permissions to configure the cluster.
  To extend system:masters permissions to other users and roles, you must add the aws-auth ConfigMap to the
  configuration of the Amazon EKS cluster. The ConfigMap allows other IAM entities, such as users and roles,
  to access the Amazon EKS cluster.
  */

  map_users = [
    {
      userarn  = aws_iam_user.techchallenge.arn
      username = "administrator"
      groups   = ["system:masters"]
    }
  ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = module.eks_sandbox.cluster_id
  addon_name        = "vpc-cni"
  addon_version     = var.addon_version_vpc_cni
  resolve_conflicts = "OVERWRITE"
  depends_on        = [module.eks_sandbox]
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = module.eks_sandbox.cluster_id
  addon_name        = "coredns"
  addon_version     = var.addon_version_coredns
  resolve_conflicts = "OVERWRITE"
  depends_on        = [module.eks_sandbox]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = module.eks_sandbox.cluster_id
  addon_name        = "kube-proxy"
  addon_version     = var.addon_version_kube_proxy
  resolve_conflicts = "OVERWRITE"
  depends_on        = [module.eks_sandbox]
}

output "eks_cluster_sandbox_worker_iam_name" {
  description = "The Sandbox Eks Cluster Worker IAM Name"
  value       = module.eks_sandbox.worker_iam_role_name
}

output "eks_cluster_sandbox_name" {
  description = "The Sandbox Eks Cluster Name"
  value       = module.eks_sandbox.cluster_id
}

output "eks_cluster_sg_id" {
  description = "The Sandbox eks cluster securitu group id"
  value       = data.aws_eks_cluster.sandbox.vpc_config[0].cluster_security_group_id
}

output "nodegroups" {
  description = "The Sandbox eks nodegroups"
  value       = module.eks_sandbox.node_groups
}

output "eks_private_subnets" {
  value = aws_subnet.eks_subnets.*.id
}
