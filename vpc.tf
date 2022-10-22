variable "cidr" {
  description = "cidr for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Private subnets IP Ranges"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "Public_Subnet IP Ranges"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# Module Infos under https://registry.terraform.io/modules/terraform-aws-modules/vpc/

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.2.0"

  name = "vpc_${var.environment}"
  cidr = var.cidr

  azs                    = data.aws_availability_zones.available.names
  private_subnets        = var.private_subnets
  public_subnets         = var.public_subnets
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  enable_dns_support     = true

  tags = {
    Terraform   = "true"
    Environment = var.environment

    # Necessary tags
    # https://docs.aws.amazon.com/eks/latest/userguide/load-balancing.html
    Name                                              = "${local.eks_cluster_name}-vpc"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  }

  public_subnet_tags = {
    Name                                              = "${local.eks_cluster_name}-public"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                          = 1
  }
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "vpc_cidr_block" {
  description = "vpc_cidr_block"
  value       = module.vpc.vpc_cidr_block
}
