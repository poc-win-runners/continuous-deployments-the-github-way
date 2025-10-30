# GitHub Actions OIDC Integration - AWS PoC

Welcome to the AWS implementation of the GitHub Actions OIDC integration workshop! This guide will help you build a secure, credential-free deployment pipeline from GitHub Actions to AWS.

## 🎯 What You'll Build

A complete CI/CD pipeline that:
- Builds a containerized web application
- Pushes container images to Amazon ECR
- Deploys to Amazon ECS using Fargate
- Uses OIDC for secure, keyless authentication
- Exposes the application via Application Load Balancer

## 🏗️ Architecture Diagram

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub Actions   │    │  AWS IAM OIDC    │    │  Amazon ECR     │
│                 │────│  Provider        │    │  Repository     │
│  - Build        │    │                  │    │                 │
│  - Test         │    │  - Trust Policy  │    │  - Container    │
│  - Deploy       │    │  - Permissions   │    │    Images       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                                              │
         │                                              │
         ▼                                              ▼
┌─────────────────┐                          ┌─────────────────┐
│  Application    │                          │  Amazon ECS     │
│  Load Balancer  │◄─────────────────────────│  Fargate        │
│                 │                          │                 │
│  - Public IP    │                          │  - Private      │
│  - Port 80/443  │                          │    Subnets      │
│  - Health Check │                          │  - Auto Scaling │
└─────────────────┘                          └─────────────────┘
```

## 🚦 Getting Started

### Phase 1: Prerequisites ✅
Follow: [Step 1: AWS Prerequisites](step-1-aws-prerequisites.md)

**Time Required**: 15 minutes  
**What you'll do**:
- Set up AWS account and CLI
- Install required tools
- Verify access permissions

### Phase 2: Infrastructure Deployment 🏗️
Follow: [Step 2: AWS Infrastructure Setup](step-2-aws-infrastructure-setup.md)

**Time Required**: 20-30 minutes  
**What you'll do**:
- Deploy CloudFormation templates
- Create VPC, ECS cluster, ECR repository
- Set up IAM OIDC provider and roles

### Phase 3: GitHub Actions Configuration 🔧
Follow: [Step 3: GitHub Actions Setup](step-3-github-actions-setup.md)

**Time Required**: 15 minutes  
**What you'll do**:
- Configure repository secrets
- Create GitHub Actions workflow
- Test the deployment pipeline

## 🆚 Azure vs AWS Comparison

This PoC provides AWS equivalents to the original Azure workshop:

| Feature | Azure Implementation | AWS Implementation |
|---------|---------------------|-------------------|
| **Container Registry** | Azure Container Registry | Amazon ECR |
| **Container Platform** | Azure App Service | Amazon ECS Fargate |
| **Load Balancing** | Built-in App Service LB | Application Load Balancer |
| **Identity Provider** | Azure AD App Registration | IAM OIDC Identity Provider |
| **Networking** | Implicit VNet | Explicit VPC with subnets |
| **Infrastructure as Code** | Bicep templates | CloudFormation templates |
| **Deployment Script** | Azure CLI (`.azcli`) | Bash script with AWS CLI |

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
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    role-session-name: github-actions-session
    aws-region: ${{ env.AWS_REGION }}
```

### Key Security Advantages

1. **No Long-term Credentials**: No access keys to manage or rotate
2. **Repository-specific Trust**: IAM role only trusts your specific repository
3. **Time-limited Tokens**: OIDC tokens expire automatically
4. **Audit Trail**: All actions logged in AWS CloudTrail
5. **Granular Permissions**: Least privilege access to AWS resources

## 💰 Cost Breakdown

### Monthly Costs (US East 1)

| Service | Free Tier | Typical Cost |
|---------|-----------|-------------|
| **ECR** | 500 MB storage | $0.10/GB/month |
| **ECS Fargate** | 20 GB-Hours | $0.04048 per vCPU hour |
| **Application Load Balancer** | None | ~$16/month |
| **NAT Gateway** | None | ~$45/month |
| **VPC** | Free | Free |

**Estimated Monthly Cost**: $60-70 for minimal usage

### Cost Optimization Tips

1. **Remove ALB if not needed**: Use ECS service discovery
2. **Use Fargate Spot**: Up to 70% savings for non-critical workloads
3. **Right-size containers**: Start with minimal CPU/memory
4. **Enable container insights selectively**: Can add CloudWatch costs

## 🧪 Testing Your Setup

### Validation Checklist

- [ ] Infrastructure deployed successfully
- [ ] GitHub secrets configured
- [ ] First deployment completed
- [ ] Application accessible via load balancer
- [ ] CloudWatch logs show container activity

### Sample Test Commands

```bash
# Test application accessibility
curl http://$(aws cloudformation describe-stacks \
  --stack-name gh-universe24-github-oidc-workshop \
  --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' \
  --output text)

# Check ECS service health
aws ecs describe-services \
  --cluster gh-universe24-cluster \
  --services gh-universe24-service \
  --query 'services[0].deployments[0].status'

# View recent container logs
aws logs tail /ecs/gh-universe24-app --follow
```

## 🚨 Troubleshooting Quick Reference

### Common Issues & Solutions

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **Stack Creation Fails** | CloudFormation rollback | Check IAM permissions, parameter values |
| **GitHub Actions Fails** | Permission denied errors | Verify role ARN, repository name in trust policy |
| **Container Won't Start** | ECS service stuck in pending | Check container image, task definition, logs |
| **Application Unreachable** | Timeout on load balancer | Check security groups, health check settings |

### Debug Resources

- **AWS CloudFormation Console**: View stack events and resources
- **ECS Console**: Monitor service health and task status
- **CloudWatch Logs**: Container application logs
- **GitHub Actions**: Workflow run details and logs

## 📚 Learning Path

### Beginner
1. Complete this workshop end-to-end
2. Understand OIDC concepts
3. Learn basic AWS ECS and ECR operations

### Intermediate
1. Customize the CloudFormation templates
2. Add HTTPS/SSL certificates
3. Implement blue-green deployments
4. Add monitoring and alerting

### Advanced
1. Multi-environment setup (dev/staging/prod)
2. Cross-region deployments
3. Advanced ECS deployment strategies
4. Custom OIDC claim validations

## 🔗 Additional Resources

### AWS Documentation
- [IAM OIDC Identity Providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [Amazon ECS Developer Guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/)
- [CloudFormation User Guide](https://docs.aws.amazon.com/cloudformation/)

### GitHub Documentation
- [OIDC Security Hardening](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS Actions](https://github.com/aws-actions)

### Community Resources
- [AWS Samples GitHub](https://github.com/aws-samples)
- [AWS Solutions Library](https://aws.amazon.com/solutions/)

## 🤝 Next Steps

After completing this workshop:

1. **Experiment**: Try different container configurations
2. **Secure**: Add HTTPS, WAF, and monitoring
3. **Scale**: Test with multiple environments
4. **Share**: Document your learnings and improvements

Happy building! 🚀