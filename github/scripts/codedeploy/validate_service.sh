#!/bin/bash
set -e

# ValidateService Hook
# Verify the application is running correctly

echo "=========================================="
echo "ValidateService: Validating deployment"
echo "=========================================="

MAX_ATTEMPTS=30
SLEEP_SECONDS=2
HEALTH_ENDPOINT="http://localhost:3000/api/health"

# Wait for application to be ready
echo "Waiting for application to respond..."
for i in $(seq 1 $MAX_ATTEMPTS); do
  if curl -f -s -o /dev/null "$HEALTH_ENDPOINT"; then
    echo "✅ Health check passed on attempt $i"
    break
  fi

  if [ $i -eq $MAX_ATTEMPTS ]; then
    echo "❌ Health check failed after $MAX_ATTEMPTS attempts"
    echo ""
    echo "PM2 Status:"
    sudo -u ec2-user pm2 list
    echo ""
    echo "Recent logs:"
    sudo -u ec2-user pm2 logs trushot-app --lines 50 --nostream || true
    exit 1
  fi

  echo "Attempt $i/$MAX_ATTEMPTS failed, retrying in ${SLEEP_SECONDS}s..."
  sleep $SLEEP_SECONDS
done

# Additional validation checks
echo ""
echo "Running additional validation checks..."

# Check if PM2 process is online
if ! sudo -u ec2-user pm2 list | grep -q "trushot-app.*online"; then
  echo "❌ PM2 process is not online"
  exit 1
fi

# Check if port 3000 is listening
if ! lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
  echo "❌ Application not listening on port 3000"
  exit 1
fi

# Check memory usage (warn if high)
MEMORY_USAGE=$(sudo -u ec2-user pm2 jlist | jq '.[0].monit.memory' 2>/dev/null || echo 0)
MEMORY_MB=$((MEMORY_USAGE / 1024 / 1024))
echo "Memory usage: ${MEMORY_MB}MB"

if [ "$MEMORY_MB" -gt 1000 ]; then
  echo "⚠️  Warning: High memory usage detected"
fi

# Test a few critical endpoints
echo ""
echo "Testing critical endpoints..."

# Test homepage
if curl -f -s -o /dev/null "http://localhost:3000/"; then
  echo "✅ Homepage responsive"
else
  echo "⚠️  Homepage not accessible"
fi

echo ""
echo "=========================================="
echo "✅ Deployment validation successful!"
echo "=========================================="
echo ""
echo "Application Status:"
sudo -u ec2-user pm2 list
