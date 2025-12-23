#!/bin/bash
set -e

PLATFORM=$1
SERVICE_NAME="${RAILWAY_SERVICE_NAME:-worker}"

if [ -z "$PLATFORM" ]; then
  echo "Usage: $0 [vercel|railway]"
  exit 1
fi

if [ "$PLATFORM" != "vercel" ] && [ "$PLATFORM" != "railway" ]; then
  echo "Error: Platform must be 'vercel' or 'railway'"
  exit 1
fi

echo "Setting environment variables for $PLATFORM..."

# For Railway, batch all variables into a single command
RAILWAY_VARS=()

# Function to set variables based on platform
set_var() {
  local key=$1
  local value=$2

  # Skip empty values
  if [ -z "$value" ]; then
    return
  fi

  if [ "$PLATFORM" = "vercel" ]; then
    # Try to update first (if exists), if fails then add (if not exists)
    vercel env update "$key" production --yes --token="$VERCEL_TOKEN" <<< "$value" || \
    vercel env add "$key" production --token="$VERCEL_TOKEN" <<< "$value"
  else
    # For Railway, batch the --set flags
    RAILWAY_VARS+=("--set" "$key=$value")
  fi
}

# Environment
set_var "NODE_ENV" "${NODE_ENV}"
set_var "NEXT_TELEMETRY_DISABLED" "${NEXT_TELEMETRY_DISABLED}"
set_var "ENABLE_CONSOLE_LOGS" "${ENABLE_CONSOLE_LOGS}"

# RDS Database
set_var "DATABASE_URL" "${DATABASE_URL}"
set_var "DB_HOST" "${DB_HOST}"
set_var "DB_PORT" "${DB_PORT}"
set_var "DB_USER" "${DB_USER}"
set_var "DB_PASSWORD" "${DB_PASSWORD}"
set_var "DB_NAME" "${DB_NAME}"

# ElastiCache Redis
set_var "REDIS_URL" "${REDIS_URL}"
set_var "ELASTICACHE_REDIS_HOST" "${ELASTICACHE_REDIS_HOST}"
set_var "ELASTICACHE_REDIS_PORT" "${ELASTICACHE_REDIS_PORT}"
set_var "ELASTICACHE_REDIS_PASSWORD" "${ELASTICACHE_REDIS_PASSWORD}"
set_var "ELASTICACHE_REDIS_TLS" "${ELASTICACHE_REDIS_TLS}"
set_var "REDIS_MAX_CONNECTIONS" "${REDIS_MAX_CONNECTIONS}"
set_var "REDIS_MIN_CONNECTIONS" "${REDIS_MIN_CONNECTIONS}"
set_var "REDIS_ACQUIRE_TIMEOUT" "${REDIS_ACQUIRE_TIMEOUT}"
set_var "REDIS_HEALTH_CHECK_INTERVAL" "${REDIS_HEALTH_CHECK_INTERVAL}"

# S3 Storage
set_var "AWS_REGION" "${AWS_REGION}"
set_var "AWS_ACCESS_KEY_ID" "${AWS_ACCESS_KEY_ID}"
set_var "AWS_SECRET_ACCESS_KEY" "${AWS_SECRET_ACCESS_KEY}"
set_var "S3_BUCKET_NAME" "${S3_BUCKET_NAME}"
set_var "S3_PUBLIC_URL" "${S3_PUBLIC_URL}"

# Turnstile
set_var "NEXT_PUBLIC_TURNSTILE_SITE_KEY" "${NEXT_PUBLIC_TURNSTILE_SITE_KEY}"
set_var "TURNSTILE_SECRET_KEY" "${TURNSTILE_SECRET_KEY}"

# Execute Railway variables in batch if platform is railway
if [ "$PLATFORM" = "railway" ] && [ ${#RAILWAY_VARS[@]} -gt 0 ]; then
  railway variables "${RAILWAY_VARS[@]}" --service "$SERVICE_NAME" --skip-deploys
fi

echo "✅ Environment variables set successfully for $PLATFORM"
