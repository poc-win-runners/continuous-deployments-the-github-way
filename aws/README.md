# AWS GitHub Actions OIDC Integration - Minimal PoC

This directory contains a **minimal AWS implementation** focused purely on demonstrating GitHub Actions OIDC integration. This is the AWS equivalent of the core OIDC functionality from the Azure workshop, without the additional application hosting complexity.

## � Focus: Pure OIDC Integration

This minimal setup demonstrates:

- **✅ OIDC Authentication**: GitHub Actions → AWS without long-term credentials
- **✅ Container Registry Access**: Push/pull images securely 
- **✅ Core Security Concept**: Federated identity with repository-specific trust

**What's NOT included** (available in full workshop):
- ❌ Application hosting (ECS, App Service)
- ❌ Load balancing and networking
- ❌ Complete CI/CD pipeline

## 📁 Directory Structure

```
aws/
├── day-0/                           # Infrastructure deployment
│   ├── minimal-oidc-poc.yaml        # Single CloudFormation template
│   └── deploy-minimal.sh            # Simple deployment script
├── day-1/
│   └── oidc-config.json            # OIDC configuration reference
└── test-oidc-workflow.yml          # Sample GitHub Actions workflow
```

## 🚀 Quick Start

### Prerequisites

1. AWS account with administrative access
2. AWS CLI v2 installed and configured (`aws configure`)
3. GitHub repository

### Step 1: Deploy Infrastructure

```bash
cd aws/day-0
./deploy-minimal.sh
```

The script will:
- Prompt for your GitHub organization and repository
- Create IAM OIDC provider and role
- Create ECR repository
- Output the values you need for GitHub secrets

### Step 2: Configure GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

- `AWS_ROLE_ARN` - IAM role ARN from deployment output
- `ECR_REPOSITORY_URI` - ECR repository URI from deployment output  
- `AWS_REGION` - AWS region you deployed to

### Step 3: Test the Integration

Copy `aws/test-oidc-workflow.yml` to `.github/workflows/` in your repository and trigger it manually or by pushing changes to the `app/` directory.

## 🧪 What Gets Created

**Resources (minimal cost):**
- 1 IAM OIDC Identity Provider (free)
- 1 IAM Role with ECR permissions (free)
- 1 ECR repository (500 MB free tier per month)

**Estimated monthly cost: $0-2** (just ECR storage)

## ✅ Testing OIDC Integration

The test workflow will:

1. ✅ **Authenticate** to AWS using OIDC (no stored credentials)
2. ✅ **Verify identity** with `aws sts get-caller-identity`
3. ✅ **Test ECR access** by describing repositories
4. ✅ **Build and push** Docker image (optional, on code changes)

## 🔐 Security Features

- **No Long-term Credentials**: Uses OIDC tokens instead of access keys
- **Repository-specific Trust**: IAM role only trusts your specific GitHub repository
- **Minimal Permissions**: Only ECR read/write access
- **Time-limited Access**: OIDC tokens expire automatically

## 🧹 Cleanup

Remove all resources:

```bash
aws cloudformation delete-stack --stack-name oidc-poc-minimal --region <your-region>
```

## 🆚 Comparison: Minimal vs Full Setup

| Component | Azure (Original) | AWS (Minimal) | AWS (Full - Available) |
|-----------|------------------|---------------|----------------------|
| **Identity** | Azure AD App Registration | IAM OIDC Provider | IAM OIDC Provider |
| **Container Registry** | Azure Container Registry | Amazon ECR | Amazon ECR |
| **Application Hosting** | Azure App Service | ❌ Not included | Amazon ECS Fargate |
| **Load Balancing** | Built-in App Service | ❌ Not included | Application Load Balancer |
| **Networking** | Implicit | ❌ Not included | VPC with subnets |
| **Monthly Cost** | ~$20-30 | ~$0-2 | ~$60-70 |
| **Deployment Time** | ~15 minutes | ~3 minutes | ~20 minutes |

## 📚 What You Learn

This minimal setup teaches you:

1. **OIDC Fundamentals**: How federated identity works between GitHub and AWS
2. **Trust Policies**: Repository-specific access control  
3. **IAM Roles**: Service-to-service authentication without credentials
4. **Container Registry Integration**: Secure image management
5. **GitHub Actions Security**: Modern CI/CD without stored secrets

Perfect for understanding the **core security concepts** before scaling to full application deployments!