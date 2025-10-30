# GitHub Actions Setup for AWS OIDC

This document explains how to configure GitHub Actions to use OIDC authentication with AWS for secure deployments.

## 🔐 GitHub Repository Secrets

After deploying the AWS infrastructure, you need to configure the following secrets in your GitHub repository.

### Required Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions → Repository secrets

Add the following secrets:

| Secret Name | Description | Example Value |
|------------|-------------|---------------|
| `AWS_REGION` | AWS region where resources are deployed | `us-east-1` |
| `AWS_ROLE_ARN` | IAM Role ARN for GitHub Actions | `arn:aws:iam::123456789012:role/gh-universe24-github-actions-role` |
| `ECR_REPOSITORY_URI` | ECR repository URI | `123456789012.dkr.ecr.us-east-1.amazonaws.com/gh-universe24-app` |
| `ECS_CLUSTER_NAME` | ECS cluster name | `gh-universe24-cluster` |
| `ECS_SERVICE_NAME` | ECS service name | `gh-universe24-service` |

### Getting Secret Values

After running the deployment script (`aws/day-0/provision.sh`), you'll find these values in:
- Terminal output
- `aws/day-0/stack-outputs.json` file

## 🚀 GitHub Actions Workflow

Create `.github/workflows/deploy.yml` in your repository:

```yaml
name: Deploy to AWS ECS

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  AWS_REGION: ${{ secrets.AWS_REGION }}
  ECR_REPOSITORY_URI: ${{ secrets.ECR_REPOSITORY_URI }}
  ECS_CLUSTER_NAME: ${{ secrets.ECS_CLUSTER_NAME }}
  ECS_SERVICE_NAME: ${{ secrets.ECS_SERVICE_NAME }}

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    name: Deploy to ECS
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials using OIDC
      uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
        role-session-name: github-actions-session
        aws-region: ${{ env.AWS_REGION }}

    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v2

    - name: Build, tag, and push image to Amazon ECR
      id: build-image
      working-directory: ./app
      env:
        IMAGE_TAG: ${{ github.sha }}
      run: |
        docker build -t $ECR_REPOSITORY_URI:$IMAGE_TAG .
        docker push $ECR_REPOSITORY_URI:$IMAGE_TAG
        echo "image=$ECR_REPOSITORY_URI:$IMAGE_TAG" >> $GITHUB_OUTPUT

    - name: Download task definition
      run: |
        aws ecs describe-task-definition \
          --task-definition gh-universe24-app \
          --query taskDefinition > task-definition.json

    - name: Fill in the new image ID in the Amazon ECS task definition
      id: task-def
      uses: aws-actions/amazon-ecs-render-task-definition@v1
      with:
        task-definition: task-definition.json
        container-name: gh-universe24-app
        image: ${{ steps.build-image.outputs.image }}

    - name: Deploy Amazon ECS task definition
      uses: aws-actions/amazon-ecs-deploy-task-definition@v1
      with:
        task-definition: ${{ steps.task-def.outputs.task-definition }}
        service: ${{ env.ECS_SERVICE_NAME }}
        cluster: ${{ env.ECS_CLUSTER_NAME }}
        wait-for-service-stability: true
```

## 🔍 OIDC Configuration Details

The OIDC integration works as follows:

1. **Identity Provider**: GitHub's OIDC provider (`https://token.actions.githubusercontent.com`)
2. **Trust Policy**: Allows GitHub Actions from your specific repository
3. **Permissions**: IAM role has permissions for ECS and ECR operations

### Trust Relationship

The IAM role trusts GitHub Actions with these conditions:
- `aud`: Must be `sts.amazonaws.com`
- `sub`: Must match `repo:OWNER/REPO:*` pattern

## 🧪 Testing the Setup

1. **Push code to main branch** - This triggers the workflow
2. **Check Actions tab** - Monitor the deployment progress
3. **Verify deployment** - Check ECS service and load balancer

### Verification Commands

```bash
# Check ECS service status
aws ecs describe-services \
  --cluster gh-universe24-cluster \
  --services gh-universe24-service

# Get load balancer DNS
aws cloudformation describe-stacks \
  --stack-name gh-universe24-github-oidc-workshop \
  --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' \
  --output text
```

## 🔧 Troubleshooting

### Common Issues

1. **Permission Denied**
   - Verify IAM role ARN is correct
   - Check trust policy includes your repository

2. **ECR Authentication Failed**
   - Ensure ECR permissions are attached to the role
   - Verify repository URI format

3. **ECS Deployment Failed**
   - Check task definition is valid
   - Verify container image exists in ECR
   - Review ECS service logs

### Debug Steps

1. Enable GitHub Actions debug logging:
   ```
   ACTIONS_STEP_DEBUG: true
   ACTIONS_RUNNER_DEBUG: true
   ```

2. Check AWS CloudTrail for API calls
3. Review ECS service events and CloudWatch logs

## 📚 Additional Resources

- [AWS IAM OIDC](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [GitHub OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS ECS Deploy Action](https://github.com/aws-actions/amazon-ecs-deploy-task-definition)