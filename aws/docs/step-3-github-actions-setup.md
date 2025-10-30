# GitHub Actions Setup for AWS OIDC

This document explains how to configure GitHub Actions to use OIDC authentication with AWS for secure container builds and ECR pushes.

## GitHub Repository Variables

After deploying the AWS infrastructure, you need to configure the following variables in your GitHub repository.

### Required Variables

Go to your GitHub repository → Settings → Secrets and variables → Actions → Repository variables

Add the following **variables**:

| Variable Name | Description | Example Value |
|------------|-------------|---------------|
| `AWS_REGION` | AWS region where resources are deployed | `eu-central-1` |
| `AWS_ACCOUNT_ID` | Your AWS account ID | `123456789012` |
| `ECR_REPOSITORY` | ECR repository name | `oidc-poc-app` |
| `ROLE_ARN` | Full IAM Role ARN for GitHub Actions | `arn:aws:iam::123456789012:role/oidc-poc-github-actions-role` |

### Alternative: Using ROLE_NAME

Instead of `ROLE_ARN`, you can use:

| Variable Name | Example Value |
|------------|-------------|
| `ROLE_NAME` | `oidc-poc-github-actions-role` |

The workflow will construct the full ARN using your account ID.

### Getting Variable Values

After running the deployment script (`aws/provision.sh`), you'll find these values in the terminal output:

```text
🔑 GitHub Variables to configure:
   AWS_ROLE_ARN: arn:aws:iam::123456789012:role/oidc-poc-github-actions-role
   ECR_REPOSITORY_URI: 123456789012.dkr.ecr.eu-central-1.amazonaws.com/oidc-poc-app
   AWS_REGION: eu-central-1
```

## 🚀 GitHub Actions Workflow

The repository already includes `.github/workflows/push-ecr.yml` that demonstrates the minimal OIDC integration:

```yaml
name: Build & Push to ECR

on:
  push:
    branches: [ main ]
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

env:
  IMAGE_TAG: ${{ github.sha }}

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
      - name: Validate required variables
        run: |
          missing=0
          if [ -z "${{ vars.AWS_REGION }}" ]; then
            echo "::error::Repository variable 'AWS_REGION' is not set."
            missing=1
          fi
          if [ -z "${{ vars.AWS_ACCOUNT_ID }}" ]; then
            echo "::error::Repository variable 'AWS_ACCOUNT_ID' is not set."
            missing=1
          fi
          if [ -z "${{ vars.ECR_REPOSITORY }}" ]; then
            echo "::error::Repository variable 'ECR_REPOSITORY' is not set."
            missing=1
          fi
          if [ -z "${{ vars.ROLE_ARN }}" ] && [ -z "${{ vars.ROLE_NAME }}" ]; then
            echo "::error::Set either ROLE_ARN or ROLE_NAME as a repository variable."
            missing=1
          fi
          if [ "$missing" -ne 0 ]; then
            exit 1
          fi

      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ vars.AWS_REGION }}
          role-to-assume: ${{ vars.ROLE_ARN || format('arn:aws:iam::{0}:role/{1}', vars.AWS_ACCOUNT_ID, vars.ROLE_NAME) }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build, tag, and push image
        run: |
          REGISTRY="${{ steps.login-ecr.outputs.registry }}"
          REPO="${{ vars.ECR_REPOSITORY }}"
          IMAGE="${REGISTRY}/${REPO}:${IMAGE_TAG}"
          LATEST="${REGISTRY}/${REPO}:latest"

          echo "Building ${IMAGE}"
          docker build -t "${IMAGE}" -t "${LATEST}" ./app

          echo "Pushing ${IMAGE} and ${LATEST}"
          docker push "${IMAGE}"
          docker push "${LATEST}"

      - name: Show pushed images
        run: |
          aws ecr describe-images \
            --repository-name "${{ vars.ECR_REPOSITORY }}" \
            --query 'imageDetails[].imageTags' --output table
```

## OIDC Configuration Details

The OIDC integration works as follows:

1. **Identity Provider**: GitHub's OIDC provider (`https://token.actions.githubusercontent.com`)
2. **Trust Policy**: Allows GitHub Actions from your specific repository
3. **Permissions**: IAM role has permissions for ECR operations only

### Trust Relationship

The IAM role trusts GitHub Actions with these conditions:

- `aud`: Must be `sts.amazonaws.com`
- `sub`: Must match `repo:OWNER/REPO:*` pattern

### Key Security Features

- **No Long-term Credentials**: Uses short-lived OIDC tokens
- **Repository-specific Trust**: Only your repository can assume the role
- **Minimal Permissions**: Only ECR read/write access
- **Automatic Validation**: Workflow validates all required variables

## Testing the Setup

### Manual Trigger

1. Go to your repository → Actions tab
2. Select "Build & Push to ECR" workflow
3. Click "Run workflow" button
4. Monitor the execution

## 📋 Verification Commands

After a successful workflow run:

```bash
# List images in your ECR repository
aws ecr list-images --repository-name oidc-poc-app

# Describe specific image
aws ecr describe-images --repository-name oidc-poc-app --image-ids imageTag=latest

# Check image details
aws ecr describe-images \
  --repository-name oidc-poc-app \
  --query 'imageDetails[0].[imagePushedAt,imageSizeInBytes,imageTags]' \
  --output table
```
