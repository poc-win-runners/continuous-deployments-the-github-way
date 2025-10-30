# AWS Prerequisites for GitHub Actions OIDC Integration

This document outlines the prerequisites needed to set up GitHub Actions OIDC authentication with AWS resources, similar to the Azure setup in the main workshop.

## 📋 Prerequisites Checklist

### 1. AWS Account Setup
- [ ] Create or access an existing AWS account
- [ ] Ensure you have administrative privileges or sufficient IAM permissions
- [ ] Note your AWS Account ID (12-digit number)
- [ ] Choose your preferred AWS region (e.g., `us-east-1`, `eu-west-1`)

### 2. AWS CLI Setup
- [ ] Install AWS CLI v2
- [ ] Configure AWS CLI with your credentials: `aws configure`
- [ ] Verify access: `aws sts get-caller-identity`

### 3. GitHub Account Setup
- [ ] Ensure you have a GitHub account
- [ ] Create a new repository or fork the workshop template
- [ ] Note your GitHub username and repository name

### 4. Required AWS Services
The following AWS services will be used in this workshop:

- **Amazon ECS (Elastic Container Service)** - Container orchestration (equivalent to Azure App Service)
- **Amazon ECR (Elastic Container Registry)** - Container registry (equivalent to Azure Container Registry)
- **AWS IAM** - Identity and Access Management for OIDC setup
- **Application Load Balancer** - Load balancing for the containerized application
- **Amazon VPC** - Virtual network for resources

### 5. Tools Required
- [ ] AWS CLI v2
- [ ] Docker (for local testing)
- [ ] Git
- [ ] A code editor (VS Code recommended)

## 💰 Cost Considerations

The AWS resources created in this workshop are designed to use free tier or low-cost services:
- ECS Fargate has a free tier with 20 GB-Hours per month
- ECR provides 500 MB of storage free per month
- Application Load Balancer costs ~$16/month (consider using ALB only when needed)

## 🔐 Security Best Practices

1. **Use IAM Roles**: Never use long-term access keys in GitHub Actions
2. **Principle of Least Privilege**: Grant only necessary permissions
3. **Enable CloudTrail**: Monitor API calls for security auditing
4. **Regular Cleanup**: Remove unused resources to avoid costs

## Next Steps

Once prerequisites are complete, proceed to [Step 2: AWS Infrastructure Setup](step-2-aws-infrastructure-setup.md).