#!/bin/bash

# Verification script for GitHub Actions EKS access
# This script helps verify if your GitHub Actions IAM role has proper access to EKS

set -e

echo "🔍 Verifying GitHub Actions EKS Access Configuration"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
GITHUB_ROLE_ARN="arn:aws:iam::154486398178:role/oidc-poc-github-actions-role"
CLUSTER_NAME="${CLUSTER_NAME:-your-cluster-name}"  # Replace with your actual cluster name
AWS_REGION="${AWS_REGION:-eu-central-1}"

echo -e "\n📋 Configuration:"
echo "GitHub Actions Role: $GITHUB_ROLE_ARN"
echo "Cluster Name: $CLUSTER_NAME"
echo "AWS Region: $AWS_REGION"

# 1. Check if kubectl is configured
echo -e "\n1️⃣  Checking kubectl configuration..."
if kubectl cluster-info &>/dev/null; then
    echo -e "${GREEN}✅ kubectl is configured and can connect to the cluster${NC}"
else
    echo -e "${RED}❌ kubectl cannot connect to the cluster${NC}"
    exit 1
fi

# 2. Check aws-auth ConfigMap for GitHub Actions role
echo -e "\n2️⃣  Checking aws-auth ConfigMap..."
if kubectl get configmap aws-auth -n kube-system &>/dev/null; then
    echo -e "${GREEN}✅ aws-auth ConfigMap exists${NC}"
    
    # Check if GitHub role is in mapRoles
    if kubectl get configmap aws-auth -n kube-system -o yaml | grep -q "oidc-poc-github-actions-role"; then
        echo -e "${GREEN}✅ GitHub Actions role found in aws-auth ConfigMap${NC}"
        
        # Show the role configuration
        echo -e "\n📝 Role configuration in aws-auth:"
        kubectl get configmap aws-auth -n kube-system -o yaml | grep -A 5 -B 5 "oidc-poc-github-actions-role" || true
    else
        echo -e "${RED}❌ GitHub Actions role NOT found in aws-auth ConfigMap${NC}"
        echo -e "${YELLOW}💡 You need to add the role to aws-auth ConfigMap${NC}"
    fi
else
    echo -e "${RED}❌ aws-auth ConfigMap not found${NC}"
fi

# 3. Test basic permissions that GitHub Actions workflow needs
echo -e "\n3️⃣  Testing required Kubernetes permissions..."

# Test namespace operations
echo -n "   - Create namespaces: "
if kubectl auth can-i create namespaces &>/dev/null; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌${NC}"
fi

# Test secret operations
echo -n "   - Create secrets: "
if kubectl auth can-i create secrets &>/dev/null; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌${NC}"
fi

# Test rolebinding operations
echo -n "   - Create rolebindings: "
if kubectl auth can-i create rolebindings &>/dev/null; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌${NC}"
fi

# Test pod operations (for Helm deployments)
echo -n "   - Manage pods: "
if kubectl auth can-i create pods &>/dev/null; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌${NC}"
fi

# 4. Check IAM role permissions (requires AWS CLI with appropriate permissions)
echo -e "\n4️⃣  Checking IAM role policies..."
echo -n "   - Checking attached policies: "
if aws iam list-attached-role-policies --role-name oidc-poc-github-actions-role &>/dev/null; then
    echo -e "${GREEN}✅${NC}"
    echo -e "\n📋 Attached policies:"
    aws iam list-attached-role-policies --role-name oidc-poc-github-actions-role --output table
else
    echo -e "${YELLOW}⚠️  Cannot check IAM policies (may need additional permissions)${NC}"
fi

# 5. Test EKS describe cluster permission
echo -e "\n5️⃣  Testing EKS permissions..."
echo -n "   - Describe EKS cluster: "
if aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" &>/dev/null; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌${NC}"
    echo -e "${YELLOW}💡 The GitHub Actions role needs eks:DescribeCluster permission${NC}"
fi

# 6. Test a simple Helm operation (if Helm is available)
echo -e "\n6️⃣  Testing Helm functionality..."
if command -v helm &>/dev/null; then
    echo -n "   - Helm list: "
    if helm list &>/dev/null; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Helm not installed locally${NC}"
fi

echo -e "\n🎯 Summary:"
echo "=================================================="
echo "If you see mostly ✅ above, your GitHub Actions workflow should be able to:"
echo "• Connect to the EKS cluster"
echo "• Create namespaces and secrets"
echo "• Install Helm charts (ARC controller and scale sets)"
echo "• Manage Kubernetes resources"
echo ""
echo "If you see ❌ marks, you may need to:"
echo "• Add the GitHub Actions IAM role to aws-auth ConfigMap"
echo "• Attach EKS permissions to the IAM role"
echo "• Verify your cluster name and region settings"

echo -e "\n🚀 To test the actual GitHub Actions workflow:"
echo "   1. Set up the required repository variables (AWS_REGION, CLUSTER_NAME, etc.)"
echo "   2. Set up the required secrets (GH_APP_ID, GH_INSTALLATION_ID, GH_PRIVATE_KEY)"
echo "   3. Run the workflow manually via GitHub Actions"