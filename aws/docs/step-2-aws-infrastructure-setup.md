# AWS Infrastructure Setup with CloudFormation

This document explains how to provision AWS infrastructure equivalent to the Azure setup, using CloudFormation templates.

## 🏗️ Architecture Overview

The AWS infrastructure mirrors the Azure setup:

| Azure Service | AWS Equivalent |
|---------------|----------------|
| Azure App Service | Amazon ECS Fargate |
| Azure Container Registry | Amazon ECR |
| Azure Resource Group | CloudFormation Stack |
| Azure AD App Registration | IAM OIDC Identity Provider + Role |

## 📁 Infrastructure Structure

```
aws/
├── day-0/
│   ├── main.yaml                    # Main CloudFormation template
│   ├── parameters.json              # Parameter values
│   ├── provision.sh                 # Deployment script
│   ├── 1-vpc-networking.yaml        # VPC and networking resources
│   ├── 2-ecr-repository.yaml        # ECR container registry
│   ├── 3-ecs-cluster.yaml          # ECS cluster and service
│   ├── 4-oidc-github-integration.yaml # GitHub OIDC setup
│   └── 5-load-balancer.yaml        # Application Load Balancer
└── day-1/
    └── oidc-config.json            # OIDC configuration for GitHub Actions
```

## 🚀 Deployment Process

### Step 1: Configure Parameters

Edit `aws/day-0/parameters.json` with your specific values:
- AWS region
- GitHub repository details
- Application settings

### Step 2: Run Deployment Script

```bash
cd aws/day-0
chmod +x provision.sh
./provision.sh
```

### Step 3: Verify Deployment

The script will output important values needed for GitHub Actions configuration.

## 🔧 What Gets Created

1. **VPC and Networking**
   - Virtual Private Cloud
   - Public and private subnets
   - Internet Gateway
   - NAT Gateway
   - Route tables

2. **Container Registry (ECR)**
   - Private ECR repository for the application
   - IAM policies for push/pull access

3. **ECS Infrastructure**
   - ECS cluster
   - ECS service definition
   - Task definition for the containerized app
   - IAM execution role

4. **Load Balancer**
   - Application Load Balancer
   - Target group
   - Security groups

5. **GitHub OIDC Integration**
   - IAM OIDC Identity Provider
   - IAM role for GitHub Actions
   - Policies for ECS and ECR access

## 📊 Outputs

After deployment, the following outputs are available:
- ECR repository URI
- ECS cluster name
- Load balancer DNS name
- IAM role ARN for GitHub Actions
- OIDC provider ARN

## 🧹 Cleanup

To remove all resources:

```bash
aws cloudformation delete-stack --stack-name github-oidc-workshop
```

## Next Steps

Proceed to [Step 3: GitHub Actions Configuration](step-3-github-actions-setup.md) to configure the CI/CD pipeline.