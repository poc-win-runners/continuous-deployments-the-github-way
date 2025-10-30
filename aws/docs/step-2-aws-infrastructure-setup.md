# AWS Infrastructure Setup with CloudFormation - Minimal PoC

This document explains how to provision minimal AWS infrastructure for GitHub Actions OIDC integration using a single CloudFormation template.

## Architecture Overview

The minimal AWS infrastructure includes only essential components for OIDC authentication:

| Component | Purpose |
|-----------|---------|
| Amazon ECR | Container registry (equivalent to Azure Container Registry) |
| IAM OIDC Identity Provider | GitHub Actions authentication endpoint |
| IAM Role | Federated access role for GitHub Actions |

## Deployment Process

### Step 1: Review Configuration

The `parameters.json` file contains your repository-specific settings:

```json
[
  {
    "ParameterKey": "GitHubOrg",
    "ParameterValue": "your-github-username"
  },
  {
    "ParameterKey": "GitHubRepo", 
    "ParameterValue": "your-repository-name"
  },
  {
    "ParameterKey": "ProjectPrefix",
    "ParameterValue": "oidc-poc"
  }
]
```

### Step 2: Run Deployment Script

```bash
cd aws
chmod +x provision.sh
./provision.sh
```

The script will:

1. Prompt for your GitHub organization and repository
2. Update the parameters file
3. Deploy the CloudFormation stack
4. Output configuration values for GitHub

### Step 3: Note the Outputs

After successful deployment, you'll see:

```text
🔑 GitHub Variables to configure:
   AWS_ROLE_ARN: arn:aws:iam::123456789012:role/oidc-poc-github-actions-role
   ECR_REPOSITORY_URI: 123456789012.dkr.ecr.eu-central-1.amazonaws.com/oidc-poc-app
   AWS_REGION: eu-central-1
```

## What Gets Created

### 1. ECR Repository

- **Purpose**: Store container images
- **Name**: `{ProjectPrefix}-app` (e.g., `oidc-poc-app`)
- **Features**: Image scanning, lifecycle policy (keeps last 5 images)

### 2. IAM OIDC Identity Provider

- **Purpose**: Trust GitHub's token issuer
- **URL**: `https://token.actions.githubusercontent.com`
- **Audience**: `sts.amazonaws.com`
- **Thumbprints**: GitHub's certificate fingerprints

### 3. IAM Role for GitHub Actions

- **Purpose**: Federated access for GitHub Actions
- **Trust Policy**: Only your specific repository
- **Permissions**: ECR read/write access
- **Condition**: Must use correct audience and repository path

## Security Configuration

### Trust Relationship

The IAM role trusts GitHub Actions with strict conditions:

```json
{
  "Effect": "Allow",
  "Principal": {
    "Federated": "arn:aws:iam::ACCOUNT:oidc-provider/token.actions.githubusercontent.com"
  },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "StringEquals": {
      "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
    },
    "StringLike": {
      "token.actions.githubusercontent.com:sub": "repo:ORG/REPO:*"
    }
  }
}
```

### ECR Permissions

The role has minimal ECR permissions:

- Push/pull images from the specific repository
- Get authentication tokens
- Describe repositories and images

## Stack Outputs

| Output | Description | Used For |
|--------|-------------|----------|
| `ECRRepositoryURI` | Full ECR repository URI | Docker push/pull commands |
| `GitHubActionsRoleArn` | IAM role ARN | GitHub Actions authentication |
| `OIDCProviderArn` | OIDC provider ARN | Reference for other stacks |

## 🧪 Verification

After deployment, verify the setup:

```bash
# Check CloudFormation stack
aws cloudformation describe-stacks --stack-name oidc-poc-minimal

# Verify ECR repository
aws ecr describe-repositories --repository-names oidc-poc-app

# Check IAM role
aws iam get-role --role-name oidc-poc-github-actions-role
```

## Next Steps

Proceed to [Step 3: GitHub Actions Setup](step-3-github-actions-setup.md) to configure the CI/CD pipeline.
