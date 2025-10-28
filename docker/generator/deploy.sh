#!/bin/bash

# TrueShot Worker - Production Deployment Script
set -e

echo "⚡ Starting TrueShot Worker deployment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="trueshot-worker"
COMPOSE_FILE="docker-compose.yml"
BUILD_CONTEXT="../../"
DEFAULT_REPLICAS=1

# Function to print colored output
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

info() {
    echo -e "${BLUE}[DEPLOY]${NC} $1"
}

# Parse command line arguments
REPLICAS=${1:-$DEFAULT_REPLICAS}

if ! [[ "$REPLICAS" =~ ^[0-9]+$ ]] || [ "$REPLICAS" -lt 1 ] || [ "$REPLICAS" -gt 10 ]; then
    error "❌ Invalid replica count. Usage: ./deploy.sh [replicas] (1-10)"
fi

info "🔧 Deploying $REPLICAS worker replica(s)"

# Check if .env.production exists
if [ ! -f "../../.env.production" ]; then
    error "❌ .env.production file not found! Please create it first."
fi

# Check if we're in the right directory
if [ ! -f "$COMPOSE_FILE" ]; then
    error "❌ docker-compose.yml not found! Run this script from docker/worker directory."
fi

log "📋 Checking prerequisites..."
docker --version > /dev/null || error "Docker not installed"
docker-compose --version > /dev/null || error "Docker Compose not installed"

log "🛑 Stopping existing workers..."
docker-compose -p $PROJECT_NAME down --remove-orphans || warn "No existing workers to stop"

log "🏗️  Building worker image..."
docker-compose -p $PROJECT_NAME build --no-cache

log "🧹 Cleaning up unused images..."
docker image prune -f || warn "Could not clean up images"

log "⚡ Starting $REPLICAS worker instance(s)..."
docker-compose -p $PROJECT_NAME up -d --scale worker=$REPLICAS

log "⏳ Waiting for workers to initialize..."
sleep 15

# Health check
log "🏥 Checking worker health..."
HEALTHY_COUNT=$(docker-compose -p $PROJECT_NAME ps | grep "healthy\|Up" | wc -l)

if [ "$HEALTHY_COUNT" -ge "$REPLICAS" ]; then
    log "✅ Workers deployed successfully!"
    info "⚡ $HEALTHY_COUNT/$REPLICAS workers are running"

    # Show container status
    echo ""
    log "📊 Worker Status:"
    docker-compose -p $PROJECT_NAME ps

    # Show recent logs
    echo ""
    log "📝 Recent worker logs:"
    docker-compose -p $PROJECT_NAME logs --tail=20 worker

    # Show scaling info
    echo ""
    info "📈 Scaling Commands:"
    info "  Scale up:   docker-compose -p $PROJECT_NAME up -d --scale worker=3"
    info "  Scale down: docker-compose -p $PROJECT_NAME up -d --scale worker=1"
    info "  Monitor:    docker-compose -p $PROJECT_NAME logs -f worker"

else
    warn "⚠️  Only $HEALTHY_COUNT/$REPLICAS workers are healthy"
    warn "📝 Check logs: docker-compose -p $PROJECT_NAME logs worker"
fi

log "🎉 Worker deployment complete!"