#!/bin/bash
set -e

# ApplicationStop Hook
# Gracefully stop the Next.js application

echo "=========================================="
echo "ApplicationStop: Stopping Next.js app"
echo "=========================================="

# Check if PM2 is managing the app
if command -v pm2 &> /dev/null; then
  echo "Stopping app with PM2..."
  sudo -u ec2-user pm2 stop trushot-app || echo "App not running or already stopped"
  sudo -u ec2-user pm2 delete trushot-app || echo "App not in PM2 process list"
else
  echo "PM2 not found, checking for systemd service..."

  # Check if systemd service exists
  if systemctl is-active --quiet trushot-app; then
    echo "Stopping systemd service..."
    systemctl stop trushot-app
  else
    echo "No running service found"
  fi
fi

# Additional cleanup: kill any lingering Node processes on port 3000
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
  echo "Found process on port 3000, terminating..."
  lsof -Pi :3000 -sTCP:LISTEN -t | xargs kill -9 || true
fi

echo "✅ Application stopped successfully"
