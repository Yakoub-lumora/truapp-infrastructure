# Custom AMI for TruShot App

This directory contains Packer templates to build a custom Amazon Machine Image (AMI) for the TruShot application.

## Why Custom AMI?

Using a pre-built custom AMI dramatically improves EC2 instance launch time:

- **Without custom AMI**: 5-10 minutes (installing Docker, packages at boot)
- **With custom AMI**: 1-2 minutes (runtime config only)

This is critical for Auto Scaling to respond quickly to traffic spikes.

## What's Pre-installed

The custom AMI includes:
- Amazon Linux 2023 (latest)
- Node.js 20.x LTS
- PM2 (process manager)
- CloudWatch Agent
- AWS CLI v2
- Security hardening (disabled root login, auto security updates)

## Build the AMI

### Prerequisites
```bash
# Install Packer
brew install packer  # macOS
# or
wget https://releases.hashicorp.com/packer/1.10.0/packer_1.10.0_linux_amd64.zip
unzip packer_1.10.0_linux_amd64.zip
sudo mv packer /usr/local/bin/

# Configure AWS credentials
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="us-east-1"
```

### Build Command
```bash
cd /home/ec2-user/tru_app/infrastructure/packer

# Validate template
packer validate app-ami.pkr.hcl

# Build AMI
packer build app-ami.pkr.hcl
```

### Build Output
```
==> amazon-ebs.app: AMI: ami-0123456789abcdef0
```

Copy the AMI ID and update your Terraform variables:
- `infrastructure/terraform/environments/dev/terraform.tfvars`
- `infrastructure/terraform/environments/prod/terraform.tfvars`

## Update AMI in Terraform

After building the AMI, update the `ami_id` variable:

```hcl
# dev/terraform.tfvars
ami_id = "ami-0123456789abcdef0"
```

Then apply Terraform:
```bash
cd infrastructure/terraform/environments/dev
terraform init
terraform plan
terraform apply
```

## Rebuild Schedule

Rebuild the AMI:
- **Monthly**: To include latest security patches
- **After major updates**: When base dependencies change (Docker, Node.js versions)
- **Automated (recommended)**: Set up CI/CD pipeline to rebuild weekly

## CI/CD Integration

Add to GitHub Actions:
```yaml
name: Build AMI
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-packer@main
      - run: |
          cd infrastructure/packer
          packer build app-ami.pkr.hcl
```

## Customization

### Change instance type for building
```bash
packer build -var 'instance_type=t3.large' app-ami.pkr.hcl
```

### Change AMI name prefix
```bash
packer build -var 'ami_name_prefix=myapp' app-ami.pkr.hcl
```

## Troubleshooting

### Packer fails to connect
- Check security group allows SSH (port 22)
- Verify AWS credentials are correct
- Check VPC/subnet settings

### AMI build takes too long
- Use a larger instance type: `-var 'instance_type=t3.large'`
- Check network connectivity

### How to test the AMI
```bash
# Launch EC2 instance with the new AMI
aws ec2 run-instances \
  --image-id ami-0123456789abcdef0 \
  --instance-type t3.medium \
  --key-name your-key \
  --security-group-ids sg-xxx \
  --subnet-id subnet-xxx

# SSH and verify
ssh ec2-user@<instance-ip>
docker --version
docker-compose --version
node --version
```

## Cost

Building an AMI costs:
- EC2 instance runtime: ~$0.05 (t3.medium for ~10 minutes)
- EBS snapshot storage: ~$0.05/GB/month
- **Total per build**: Less than $0.10
