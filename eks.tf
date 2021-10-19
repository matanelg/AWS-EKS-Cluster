#===== IAM ROLE - Let EKS permission to create resources for Kubernetes cluster. =====#
resource "aws_iam_role" "eks_cluster" {
  name               = "eks-cluster" # The name of the role
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


#===== ATTACH POLICY TO IAM - What resources Kubernetes can apply. =====# 
resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" # The ARN of the policy you want to apply
  role       = aws_iam_role.eks_cluster.name                    # The role the policy should be applied to
}


#===== CREATE CLUSTER =====# 
resource "aws_eks_cluster" "eks" {
  name     = "eks"                        # Name of the cluster.
  role_arn = aws_iam_role.eks_cluster.arn # The Amazon Resource Name (ARN) of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf
  version  = "1.21"                       # Desired Kubernetes master version
  vpc_config {
    endpoint_private_access = false # Indicates whether or not the Amazon EKS private API server endpoint is enabled
    endpoint_public_access  = true  # Indicates whether or not the Amazon EKS public API server endpoint is enabled
    # Must be in at least two different availability zones
    subnet_ids = [
      aws_subnet.private-01-1a.id,
      aws_subnet.private-02-1b.id,
      aws_subnet.public-01-1a.id,
      aws_subnet.public-02-1b.id
    ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy
  ]
}


# Resource: 
# aws_iam_role - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
# aws_iam_role_policy_attachment - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
# AmazonEKSClusterPolicy-  https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKSClusterPolicy
# aws_eks_cluster - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
