# AWS Prerequisites for GitHub Actions OIDC Integration - Minimal PoC

This document outlines the prerequisites needed to set up a minimal GitHub Actions OIDC authentication with AWS ECR (container registry only).

## Prerequisites Checklist

### 1. AWS Account Setup

- [ ] Create or access an existing AWS account
- [ ] Ensure you have administrative privileges or sufficient IAM permissions
- [ ] Note your AWS Account ID (12-digit number)
- [ ] Choose your preferred AWS region (e.g., `us-east-1`, `eu-central-1`)

### 2. AWS CLI Setup

- [ ] Install AWS CLI v2
- [ ] Configure AWS CLI with your credentials: `aws configure`
- [ ] Verify access: `aws sts get-caller-identity`

### 3. GitHub Account Setup

- [ ] Ensure you have a GitHub account
- [ ] Create a new repository or fork the workshop template
- [ ] Note your GitHub username and repository name

### 4. Required AWS Services

The following AWS services will be used in this minimal setup:

- **Amazon ECR (Elastic Container Registry)** - Container registry (equivalent to Azure Container Registry)
- **AWS IAM** - Identity and Access Management for OIDC setup

## Next Steps

Once prerequisites are complete, proceed to [Step 2: AWS Infrastructure Setup](step-2-aws-infrastructure-setup.md).
