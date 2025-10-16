#!/bin/bash
set -e

# ApplicationStart Hook
# Start the Next.js application

echo "=========================================="
echo "ApplicationStart: Starting Next.js app"
echo "=========================================="

cd /opt/app

# Ensure environment variables are loaded
if [ ! -f .env.production.local ]; then
  echo "⚠️  Warning: .env.production.local not found"
fi

# Start the application with PM2
echo "Starting app with PM2..."

# Stop and delete any existing PM2 process
sudo -u ec2-user pm2 stop trushot-app 2>/dev/null || true
sudo -u ec2-user pm2 delete trushot-app 2>/dev/null || true

# Start the application using ecosystem config
sudo -u ec2-user bash -c 'cd /opt/app && pm2 start ecosystem.config.js'

# Save PM2 process list
sudo -u ec2-user pm2 save

# Setup PM2 to start on system boot
env PATH=$PATH:/usr/bin pm2 startup systemd -u ec2-user --hp /home/ec2-user || true

# Wait for app to be ready
echo "Waiting for application to start..."
sleep 5

# Check if the process is running
if sudo -u ec2-user pm2 list | grep -q "trushot-app.*online"; then
  echo "✅ Application started successfully"
else
  echo "❌ Application failed to start"
  sudo -u ec2-user pm2 logs trushot-app --lines 50 --nostream
  exit 1
fi
