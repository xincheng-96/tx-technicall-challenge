variable "region" {
  description = "Region that the instances will be created"
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "The environment this resource will be deployed in."
  type        = string
}

variable "github_repo" {
  description = "The github repo name"
  type        = string
  default     = "sandbox"
}

terraform {
  required_version = "1.0.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.47.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.3.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.2.0"
    }
  }
}

provider "aws" {
  region                  = "eu-central-1"
  shared_credentials_file = "./.aws/creds"
  profile                 = "AWSAdministratorAccess"
  default_tags {
    tags = {
      Landscape   = var.environment
      Github-Repo = var.github_repo
    }
  }
}


provider "kubernetes" {
  # If this provider is removed while removing the eks.tf file in order to destroy the cluster from a local machine,
  # please switch context in kubectl and select the config for the cluster in the correct environment, since without 
  # these setting the provider will use the kubeconfig selected on the local machine when destroying resources. 
  # More info https://jira.tx.group/browse/FUM-594
  host                   = data.aws_eks_cluster.sandbox.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.sandbox.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.sandbox.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.sandbox.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.sandbox.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.sandbox.token
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Terraform state backend setup
# The S3 repo has been manually created in AWS
# ---------------------------------------------------------------------------------------------------------------------

#terraform {
 # backend "s3" {
  #  region  = "eu-central-1"
   # bucket  = "tfstate-sandbox"
    #key     = "techchallenge/terraform_state"
#    shared_credentials_file = ".aws/creds"
 #   profile                 = "AWSAdministratorAccess"
  #  encrypt = "true"
#  }
#}