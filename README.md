# AWS-EKS-Cluster
Example of how to create EKS Cluster via Terraform & Auto Scale Nodes.

## Quick Start

### Prerequests
* Terraform 	v1.0.7
* aws-cli 	2.2.21 
* kubectl 	v1.22.3
* eksctl 	0.68.0
* Make sure you have administrator premission to creating resources.

### 01. Configure your aws credentials at ~/.aws/credentials
```bash
[default]
aws_access_key_id = ""
aws_secret_access_key = ""
```

### 02. Clone repository & Deploy Cluster
```bash
git clone https://github.com/matanelg/AWS-EKS-Cluster.git
cd AWS-EKS-Cluster/Terraform
terraform init
rettafom plan
terraform apply -auto-approve
```

### 03. Set Up & Deploy Autoscaler
```bash
cd ../Kubernetes
bash oidc-autoscale-role.sh
```

## Summary
With terraform we create network resources and assign it to EKS cluster that also created by terraform.<br />
The next step is to create OIDC Provider & IAM Role for Kubernetes Service Account.<br />
Now, this step is much easier with eksctl so i choose to use that approach.<br />

* Note: 
  * You should probably want to stick to one IAC for each of your infrastructure deployments, it easier for maintenance.
  * Check Out [this repository](https://github.com/matanelg/EKS-ALB-Ingress-Controller) for create OIDC & Web Identity Role using terraform only.
  * Check Out code remarks for more specificies info.

## Demo


