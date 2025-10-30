# GitHub Actions OIDC Integration - AWS Minimal PoC

This guide demonstrates the core concept of secure, credential-free authentication between GitHub Actions and AWS.

## Architecture Diagram

```text
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ GitHub Actions  │    │  AWS IAM OIDC    │    │  Amazon ECR     │
│                 │────│  Provider        │    │  Repository     │
│  - Build        │    │                  │    │                 │
│  - Test         │    │  - Trust Policy  │    │  - Container    │
│  - Push to ECR  │    │  - Permissions   │    │    Images       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Getting Started

### Phase 1: Prerequisites

Follow: [Step 1: AWS Prerequisites](step-1-aws-prerequisites.md)

### Phase 2: Infrastructure Deployment

Follow: [Step 2: AWS Infrastructure Setup](step-2-aws-infrastructure-setup.md)

### Phase 3: GitHub Actions Configuration

Follow: [Step 3: GitHub Actions Setup](step-3-github-actions-setup.md)

## 🔐 Security Benefits

### OIDC vs Traditional Methods

**❌ Traditional Approach (Not Recommended)**:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

**✅ OIDC Approach (Recommended)**:

```yaml
- name: Configure AWS credentials using OIDC
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ vars.ROLE_ARN }}
    aws-region: ${{ vars.AWS_REGION }}
```

### Key Security Advantages

1. **No Long-term Credentials**: No access keys to manage or rotate
2. **Repository-specific Trust**: IAM role only trusts your specific repository
3. **Time-limited Tokens**: OIDC tokens expire automatically
4. **Audit Trail**: All actions logged in AWS CloudTrail
5. **Granular Permissions**: Least privilege access to AWS resources

## Additional Resources

### AWS Documentation

- [IAM OIDC Identity Providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)

### GitHub Documentation

- [OIDC Security Hardening](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS Actions](https://github.com/aws-actions)
