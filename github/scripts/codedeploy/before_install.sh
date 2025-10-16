#!/bin/bash
set -e

# BeforeInstall Hook
# Prepare the environment before installing new version

echo "=========================================="
echo "BeforeInstall: Preparing environment"
echo "=========================================="

# Create application directory if it doesn't exist
mkdir -p /opt/app

# Backup current deployment (for rollback)
if [ -d "/opt/app/.next" ]; then
  echo "Backing up current deployment..."
  BACKUP_DIR="/opt/app-backup-$(date +%Y%m%d-%H%M%S)"
  cp -r /opt/app "$BACKUP_DIR"
  echo "Backup created at: $BACKUP_DIR"

  # Keep only last 3 backups
  ls -dt /opt/app-backup-* 2>/dev/null | tail -n +4 | xargs rm -rf || true
fi

# Clean up old deployment files (except node_modules to speed up)
echo "Cleaning up old deployment files..."
cd /opt/app
find . -maxdepth 1 ! -name 'node_modules' ! -name '.' ! -name '..' -exec rm -rf {} + || true

# Ensure correct ownership
chown -R ec2-user:ec2-user /opt/app

echo "✅ Environment prepared successfully"
