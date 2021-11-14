
#===== Create IAM role for EKS Node Group =====#
resource "aws_iam_role" "nodes_general" {
  name               = "eks-node-group"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }, 
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

#===== Attach policies to the IAM role =====#
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy_general" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" # The ARN of the policy you want to apply.
  role       = aws_iam_role.nodes_general.name                     # The role the policy should be applied to
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy_general" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes_general.name                
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes_general.name 
}


resource "aws_eks_node_group" "nodes_general" {
  cluster_name    = aws_eks_cluster.eks.name # Name of the EKS Cluster.
  node_group_name = "nodes-01"               # Name of the EKS Node Group.

  # Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Node Group.
  node_role_arn = aws_iam_role.nodes_general.arn

  # These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER_NAME 
  subnet_ids = [
    aws_subnet.private-01-1a.id,
    aws_subnet.private-02-1b.id
  ]

  # Configuration block with scaling settings
  scaling_config {
    desired_size = 2  # Desired number of worker nodes.
    max_size     = 10 # Maximum number of worker nodes.
    min_size     = 1  # Minimum number of worker nodes.
  }

  ami_type             = "AL2_x86_64" # Valid values: AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64
  capacity_type        = "SPOT"       # Valid values: ON_DEMAND, SPOT
  disk_size            = 8            # Disk size in GiB for worker nodes
  force_update_version = false        # Force version update if existing pods are unable to be drained due to a pod disruption budget issue.
  instance_types       = ["t3.small"] # List of instance types associated with the EKS Node Group

  labels = {
    role = "nodes-general"
  }
  version = "1.20" # Kubernetes version

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy_general,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy_general,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]
}


# Resource: 
# aws_iam_role - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
# aws_iam_role_policy_attachment - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
# 01. AmazonEKSWorkerNodePolicy - https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKSWorkerNodePolicy
# 02. AmazonEKS_CNI_Policy - https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKS_CNI_Policy
# 03. AmazonEC2ContainerRegistryReadOnly - https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEC2ContainerRegistryReadOnly
# aws_eks_node_group - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
