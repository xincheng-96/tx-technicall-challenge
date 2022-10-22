/*
    Sandbox EKS variables
*/
cluster_version          = "1.21"
addon_version_kube_proxy = "v1.21.2-eksbuild.2"
addon_version_coredns    = "v1.8.4-eksbuild.1"
addon_version_vpc_cni    = "v1.9.0-eksbuild.1"
control_plane_logs       = ["api", "audit", "controllerManager", "scheduler"]
private_eks_subnets      = ["10.0.208.0/20", "10.0.224.0/20", "10.0.240.0/20"]

node_groups = {
  sandbox = {
    min_capacity     = "1"
    desired_capacity = "2"
    max_capacity     = "3"
    instance_types   = ["t3.small"]
    k8s_labels = {
      k8s-node = "sandbox"
    }
    additional_tags = {
      Env = "sandbox"
    }
  }
}
environment = "sandbox"
