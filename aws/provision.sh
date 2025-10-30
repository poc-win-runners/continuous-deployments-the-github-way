#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

echo "🚀 Minimal GitHub Actions OIDC Integration PoC"
echo "=============================================="

# Check prerequisites
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq not found. Please install jq to parse JSON parameters"
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured"
    exit 1
fi

# Configuration files
parameters_file="${SCRIPT_DIR}/parameters.json"
template_file="${SCRIPT_DIR}/minimal-oidc-poc.yaml"

# Load existing parameters if available
if [[ -f "${parameters_file}" ]]; then
    echo "📄 Loading existing parameters from ${parameters_file}"
    existing_github_org=$(jq -r '.[] | select(.ParameterKey=="GitHubOrg") | .ParameterValue' "${parameters_file}")
    existing_github_repo=$(jq -r '.[] | select(.ParameterKey=="GitHubRepo") | .ParameterValue' "${parameters_file}")
    existing_project_prefix=$(jq -r '.[] | select(.ParameterKey=="ProjectPrefix") | .ParameterValue' "${parameters_file}")
else
    existing_github_org=""
    existing_github_repo=""
    existing_project_prefix="oidc-poc"
fi

# Get configuration with defaults from parameters file
if [[ -n "${existing_github_org}" && "${existing_github_org}" != "null" ]]; then
    read -p "Enter your GitHub username/organization (current: ${existing_github_org}): " github_org
    github_org=${github_org:-${existing_github_org}}
else
    read -p "Enter your GitHub username/organization: " github_org
fi

if [[ -n "${existing_github_repo}" && "${existing_github_repo}" != "null" ]]; then
    read -p "Enter your GitHub repository name (current: ${existing_github_repo}): " github_repo
    github_repo=${github_repo:-${existing_github_repo}}
else
    read -p "Enter your GitHub repository name: " github_repo
fi

if [[ -n "${existing_project_prefix}" && "${existing_project_prefix}" != "null" ]]; then
    read -p "Enter project prefix (current: ${existing_project_prefix}): " project_prefix
    project_prefix=${project_prefix:-${existing_project_prefix}}
else
    read -p "Enter project prefix (default: oidc-poc): " project_prefix
    project_prefix=${project_prefix:-oidc-poc}
fi

read -p "Enter AWS region (default: eu-central-1): " region
region=${region:-eu-central-1}

# Update parameters file
echo "💾 Updating parameters file..."
jq --arg github_org "${github_org}" \
   --arg github_repo "${github_repo}" \
   --arg project_prefix "${project_prefix}" \
   'map(if .ParameterKey == "GitHubOrg" then .ParameterValue = $github_org
        elif .ParameterKey == "GitHubRepo" then .ParameterValue = $github_repo
        elif .ParameterKey == "ProjectPrefix" then .ParameterValue = $project_prefix
        else . end)' \
   "${parameters_file}" > "${parameters_file}.tmp" && mv "${parameters_file}.tmp" "${parameters_file}"

stack_name="${project_prefix}-minimal"

echo ""
echo "📋 Configuration:"
echo "   GitHub Org: ${github_org}"
echo "   GitHub Repo: ${github_repo}"
echo "   Project Prefix: ${project_prefix}"
echo "   AWS Region: ${region}"
echo "   Stack Name: ${stack_name}"
echo "   Parameters File: ${parameters_file}"
echo ""

# Create the stack
echo "🏗️  Creating minimal OIDC stack..."
aws cloudformation create-stack \
    --stack-name "${stack_name}" \
    --template-body "file://${template_file}" \
    --parameters "file://${parameters_file}" \
    --capabilities CAPABILITY_NAMED_IAM \
    --region "${region}"

echo "⏳ Waiting for stack creation..."
aws cloudformation wait stack-create-complete \
    --stack-name "${stack_name}" \
    --region "${region}"

if [ $? -eq 0 ]; then
    echo "✅ OIDC Integration created successfully!"
    echo ""
    
    # Get outputs
    role_arn=$(aws cloudformation describe-stacks --stack-name "${stack_name}" --region "${region}" --query 'Stacks[0].Outputs[?OutputKey==`GitHubActionsRoleArn`].OutputValue' --output text)
    ecr_uri=$(aws cloudformation describe-stacks --stack-name "${stack_name}" --region "${region}" --query 'Stacks[0].Outputs[?OutputKey==`ECRRepositoryURI`].OutputValue' --output text)
    
    echo "🔑 GitHub Secrets to configure:"
    echo "   AWS_ROLE_ARN: ${role_arn}"
    echo "   ECR_REPOSITORY_URI: ${ecr_uri}"
    echo "   AWS_REGION: ${region}"
    echo ""
    echo "🧪 Test workflow snippet:"
    echo "   - name: Configure AWS credentials"
    echo "     uses: aws-actions/configure-aws-credentials@v4"
    echo "     with:"
    echo "       role-to-assume: \${{ secrets.AWS_ROLE_ARN }}"
    echo "       aws-region: \${{ secrets.AWS_REGION }}"
    echo ""
    echo "   - name: Test ECR access"
    echo "     run: |"
    echo "       aws ecr get-login-password --region \${{ secrets.AWS_REGION }} | \\"
    echo "       docker login --username AWS --password-stdin \${{ secrets.ECR_REPOSITORY_URI }}"
    echo ""
    echo "🧹 To cleanup: aws cloudformation delete-stack --stack-name ${stack_name} --region ${region}"
else
    echo "❌ Stack creation failed"
    exit 1
fi