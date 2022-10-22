variable "cluster_autoscaler_version" {
  default = "8.0.0"
}

resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  policy_arn = aws_iam_policy.worker_autoscaling.arn
  role       = module.eks_sandbox.worker_iam_role_name
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-worker-autoscaling-${module.eks_sandbox.cluster_id}"
  description = "EKS worker node autoscaling policy for cluster ${module.eks_sandbox.cluster_id}"
  policy      = data.aws_iam_policy_document.worker_autoscaling.json
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks_sandbox.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

resource "helm_release" "cluster-autoscaler" {
  name       = "autoscaler"
  repository = "https://charts.helm.sh/stable"
  chart      = "cluster-autoscaler"
  version    = var.cluster_autoscaler_version
  namespace  = "kube-system"
  values = [
    templatefile("values/cluster-autoscaler.yaml", {
      eks_cluster_name = local.eks_cluster_name
    })
  ]
}

# Used by HPA to scale pods based on CPU and memory
resource "helm_release" "metrics-server" {
  name       = "metrics-server"
  repository = "https://charts.helm.sh/stable"
  chart      = "metrics-server"
  version    = "2.11.2"
  namespace  = "kube-system"
  values = [
    file("values/metrics-server.yaml")
  ]
}
