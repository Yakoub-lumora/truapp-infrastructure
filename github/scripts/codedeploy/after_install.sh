#!/bin/bash
set -e

# AfterInstall Hook
# Install dependencies and perform post-installation tasks

echo "=========================================="
echo "AfterInstall: Installing dependencies"
echo "=========================================="

cd /opt/app

# Ensure correct ownership
chown -R ec2-user:ec2-user /opt/app

# Install/update Node.js dependencies
echo "Installing Node.js dependencies..."
sudo -u ec2-user bash -c 'cd /opt/app && npm ci --production'

# Load environment variables from SSM Parameter Store
echo "Loading environment variables from SSM..."
export AWS_REGION=${AWS_REGION:-us-east-1}
export PROJECT_NAME=${PROJECT_NAME:-trushot}
export ENVIRONMENT=${ENVIRONMENT:-prod}

# Create .env file from SSM parameters
sudo -u ec2-user bash -c "cat > /opt/app/.env.production.local << 'EOF'
# Auto-generated from SSM Parameter Store
NODE_ENV=production
EOF"

# Fetch all parameters from SSM and append to .env
aws ssm get-parameters-by-path \
  --path "/${PROJECT_NAME}/${ENVIRONMENT}/" \
  --with-decryption \
  --region "$AWS_REGION" \
  --query 'Parameters[*].[Name,Value]' \
  --output text | while read -r name value; do
    # Extract parameter name (remove path prefix)
    param_name=$(echo "$name" | sed "s|/${PROJECT_NAME}/${ENVIRONMENT}/||")
    echo "$param_name=$value" >> /opt/app/.env.production.local
  done

# Set correct permissions for .env file
chown ec2-user:ec2-user /opt/app/.env.production.local
chmod 600 /opt/app/.env.production.local

echo "✅ Dependencies installed successfully"
