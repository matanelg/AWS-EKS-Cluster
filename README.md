# AWS-EKS-Cluster

This repository comes to demonstrate how to create cluster & node group with AWS EKS via terraform.<br />
With terraform we can create network resources and assign it to the cluster in one place.<br />

## Summary

### Network
1. Dedicated VPC
2. 2 public subnets
3. 2 private subnets
4. 2 availability zones (Public & Private in each az)
5. Igw & Nat (for later use)
6. Route Tables
7. Route Table Association

### IAM Role & Policies
1. Cluster Role - Let EKS permission to create/use aws resources by cluster.
2. Policy - [AmazonEKSClusterPolicy](https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKSClusterPolicy)

1. Node Group Role - Let EC2 permission to create/use aws resources by instances.
2. Policy - [AmazonEKSWorkerNodePolicy](https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKSWorkerNodePolicy)
3. Policy - [AmazonEKS_CNI_Policy](https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKS_CNI_Policy)
4. Policy - [AmazonEC2ContainerRegistryReadOnly](https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEC2ContainerRegistryReadOnly)

### Cluser & Nodegroup
1. Cluster on dedicated VPC & subnets.
2. Worker nodes on private subnets.
3. Scaling configuration - desired size = 2, max size = 10, min_size = 1.
4. Instances type - spot instances t3.small


## Quick Start

### 01. Export your aws access key & secret key 
(Make sure the user have premission to creating resources).
```bash
export AWS_ACCESS_KEY=""
export AWS_SECRET_KEY=""
```

### 02. Clone repository and run terraform as follow 
(Make sure you have terraform install).
```bash
git clone https://github.com/matanelg/AWS-EKS-Cluster.git
cd AWS-EKS-Cluster
terraform init
rettafom plan
terraform apply -auto-approve
```






