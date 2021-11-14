#!/bin/bash

# 00. Connect to the Cluster
rm ~/.kube/config
aws eks --region us-east-1 update-kubeconfig --name eks --profile default


# 01. Create iam policy for kubernetes serviceaccount
policy_arn=$(aws iam list-policies --query 'Policies[?PolicyName==`AmzonEKSClusterAutoScalerPolicy`].Arn' --output text)
if [[ -z $policy_arn ]] # sd
then
	echo "policy is not exist, creating new one"
	aws iam create-policy \
    --policy-name AmzonEKSClusterAutoScalerPolicy \
    --policy-document file://Policy/AmzonEKSClusterAutoScalerPolicy.json
else
	echo "policy exist"
fi


# 02. Create & Associate IAM OIDC Provider for our EKS Cluster
eksctl utils associate-iam-oidc-provider \
    --region us-east-1 \
    --cluster eks \
    --approve


# 03. Create an AWS IAM role and bounds that to Kubernetes service account (cloudformation resource stack)
policy_arn=$(aws iam list-policies --query 'Policies[?PolicyName==`AmzonEKSClusterAutoScalerPolicy`].Arn' --output text)
eksctl create iamserviceaccount \
    --region us-east-1 \
    --name cluster-autoscaler \
    --namespace kube-system \
    --cluster eks \
    --attach-policy-arn $policy_arn \
    --override-existing-serviceaccounts \
    --approve


# 05. Deploy AutoScale [Create Rbac Roles/Binding for Service Account , AutoScaleDeployment(Controller), Nginx Deployment]
kubectl apply -f k8s

