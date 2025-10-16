#!/bin/bash
set -e

# Create Deployment Package Script
# This script runs in GitHub Actions to create the deployment package

GITHUB_SHA=${GITHUB_SHA:-"local"}
PACKAGE_NAME="deployment-${GITHUB_SHA::8}.tar.gz"

echo "=========================================="
echo "Creating deployment package"
echo "Package name: $PACKAGE_NAME"
echo "=========================================="

# Create package directory
mkdir -p deploy-package

echo "Copying application files..."
# Copy built application
cp -r .next deploy-package/
echo "✓ .next/ copied"

cp -r public deploy-package/
echo "✓ public/ copied"

cp package*.json deploy-package/
echo "✓ package files copied"

# Copy Next.js config (either .js or .mjs)
cp next.config.js deploy-package/ 2>/dev/null && echo "✓ next.config.js copied" || true
cp next.config.mjs deploy-package/ 2>/dev/null && echo "✓ next.config.mjs copied" || true

# Copy deployment script
echo "Copying deployment script..."
cp github/scripts/deploy.sh deploy-package/
chmod +x deploy-package/deploy.sh
echo "✓ deploy.sh copied"

# Copy PM2 ecosystem config
echo "Copying PM2 config..."
cp github/ecosystem.config.js deploy-package/
echo "✓ ecosystem.config.js copied"

# Copy CodeDeploy configuration
echo "Copying CodeDeploy files..."
cp appspec.yml deploy-package/
echo "✓ appspec.yml copied"

# Copy CodeDeploy scripts
mkdir -p deploy-package/github/scripts/codedeploy
cp github/scripts/codedeploy/*.sh deploy-package/github/scripts/codedeploy/
chmod +x deploy-package/github/scripts/codedeploy/*.sh
echo "✓ CodeDeploy scripts copied"

# Create the tarball
echo "Creating tarball..."
tar -czf "$PACKAGE_NAME" -C deploy-package .
echo "✓ Tarball created: $PACKAGE_NAME"

# Get size
SIZE=$(du -h "$PACKAGE_NAME" | cut -f1)
echo "Package size: $SIZE"

# Cleanup
rm -rf deploy-package
echo "✓ Cleaned up temporary files"

echo "=========================================="
echo "✓ Deployment package ready: $PACKAGE_NAME"
echo "=========================================="
