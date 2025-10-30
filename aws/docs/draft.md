Required IAM Permissions
Your workflow needs to perform these AWS actions:

Update kubeconfig - Connect to the EKS cluster
Deploy to Kubernetes - Manage pods, secrets, role bindings, etc.
Here are the minimum required IAM policy statements that need to be attached to your oidc-poc-github-actions-role:

1. EKS Cluster Access Policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EKSClusterAccess",
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:ListClusters"
            ],
            "Resource": [
                "arn:aws:eks:*:154486398178:cluster/*"
            ]
        }
    ]
}

2. Optional: ECR Access (if pulling container images from ECR)

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ECRAccess",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage"
            ],
            "Resource": "*"
        }
    ]
}

1. IAM Policy Updates
Attach the EKS access policy to your existing oidc-poc-github-actions-role:

# Create the policy
aws iam create-policy \
    --policy-name GitHubActionsEKSAccess \
    --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "EKSClusterAccess",
                "Effect": "Allow",
                "Action": [
                    "eks:DescribeCluster",
                    "eks:ListClusters"
                ],
                "Resource": [
                    "arn:aws:eks:*:154486398178:cluster/*"
                ]
            }
        ]
    }'

# Attach it to your existing role
aws iam attach-role-policy \
    --role-name oidc-poc-github-actions-role \
    --policy-arn arn:aws:iam::154486398178:policy/GitHubActionsEKSAccess


2. EKS Cluster RBAC (Most Important!)
You need to add your GitHub Actions IAM role to the EKS cluster's aws-auth ConfigMap so it can authenticate to Kubernetes:

# Connect to your EKS cluster first
aws eks update-kubeconfig --name YOUR_CLUSTER_NAME --region YOUR_REGION

# Add the GitHub Actions role to aws-auth ConfigMap
kubectl patch configmap/aws-auth -n kube-system --type merge -p '{
  "data": {
    "mapRoles": "[{\"rolearn\":\"arn:aws:iam::154486398178:role/oidc-poc-github-actions-role\",\"username\":\"github-actions\",\"groups\":[\"system:masters\"]}]"
  }
}'

