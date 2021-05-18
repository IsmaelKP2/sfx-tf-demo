
resource "aws_eks_cluster" "eks_fargate_cluster" {
  name     = var.eks_fargate_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  vpc_config {
    # subnet_ids =  concat(var.public_subnets, var.private_subnets)
    subnet_ids = concat(aws_subnet.eks_fargate_public.*.id, aws_subnet.eks_fargate_private.*.id)
  }
   
  timeouts {
     delete    =  "30m"
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy1,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController1,
    aws_cloudwatch_log_group.cloudwatch_log_group
  ]
}

resource "aws_iam_policy" "eks_fargate_cluster_cloudwatch_metrics_policy" {
  name = "${var.environment}-eks-fargate-cluster-cloudwatch-metrics-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.environment}-eks-cluster-role"
  description = "Allow cluster to manage node groups, fargate nodes and cloudwatch logs"
  force_detach_policies = true
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com",
          "eks-fargate-pods.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_fargate_cloudwatch_metrics_policy" {
  policy_arn = aws_iam_policy.eks_fargate_cluster_cloudwatch_metrics_policy.arn
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = "${var.eks_fargate_cluster_name}/cluster"
  retention_in_days = 30

  tags = {
    Name        = "${var.eks_fargate_cluster_name}-cloudwatch-log-group"
  }
}

resource "aws_eks_fargate_profile" "eks_fargate" {
  cluster_name           = aws_eks_cluster.eks_fargate_cluster.name
  fargate_profile_name   = "${var.eks_fargate_cluster_name}-profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn
  subnet_ids             = aws_subnet.eks_fargate_private.*.id

  selector {
    namespace = var.fargate_namespace
  }

  timeouts {
    create   = "30m"
    delete   = "30m"
  }
}


#### Core DNS Fargate Profile Start ####

resource "aws_eks_fargate_profile" "eks_fargate_core_dns_profile" {
  cluster_name           = aws_eks_cluster.eks_fargate_cluster.name
  fargate_profile_name   = "${var.eks_fargate_cluster_name}-core-dns-profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn
  subnet_ids             = aws_subnet.eks_fargate_private.*.id
  

  selector {
    namespace = "kube-system"
    labels = {
      # eks.amazonaws.com/k8s-app = "kube-dns"
      k8s-app = "kube-dns"
      # compute-type = "fargate"
    }
  }

  timeouts {
    create   = "30m"
    delete   = "30m"
  }
}



# {
#     "fargateProfileName": "coredns",
#     "clusterName": "<dev>",
#     "podExecutionRoleArn": "<arn:aws:iam::111122223333:role/AmazonEKSFargatePodExecutionRole>",
#     "subnets": [
#         "subnet-<0b64dd020cdff3864>",
#         "subnet-<00b03756df55e2b87>",
#         "subnet-<0418fcb68ed294abf>"
#     ],
#     "selectors": [
#         {
#             "namespace": "kube-system",
#             "labels": {
#                 "k8s-app": "kube-dns"
#             }
#         }
#     ]
# }

#### Core DNS Fargate Profile End ####

resource "aws_iam_role" "eks_fargate_role" {
  name = "${var.environment}-eks-fargate-cluster-role"
  description = "Allow fargate cluster to allocate resources for running pods"
  force_detach_policies = true
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com",
          "eks-fargate-pods.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_fargate_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_fargate_role.name
}

# resource "aws_eks_node_group" "eks_fargate_node_group" {
#   cluster_name    = aws_eks_cluster.eks_fargate_cluster.name
#   node_group_name = "${var.eks_fargate_cluster_name}-node_group"
#   node_role_arn   = aws_iam_role.eks_fargate_node_group_role.arn
#   subnet_ids      = aws_subnet.eks_fargate_public.*.id

#   scaling_config {
#     desired_size = 2
#     max_size     = 3
#     min_size     = 2
#   }

#   instance_types  = [var.eks_fargate_node_group_instance_types]

#   depends_on = [
#     aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
#   ]
# }

# resource "aws_iam_role" "eks_fargate_node_group_role" {
#   name = "${var.environment}-eks-fargate-node-group_role"

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.eks_fargate_node_group_role.name
# }

# resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks_fargate_node_group_role.name
# }

# resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.eks_fargate_node_group_role.name
# }

data "tls_certificate" "auth" {
  url = aws_eks_cluster.eks_fargate_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.auth.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_fargate_cluster.identity[0].oidc[0].issuer
}

