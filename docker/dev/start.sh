#!/bin/bash

# TrueShot Development Environment Startup Script
set -e

echo "🚀 Starting TrueShot Development Environment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
log() {
    echo -e "${GREEN}[DEV]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Configuration
PROJECT_NAME="trueshot-dev"
COMPOSE_FILE="docker-compose.yml"

# Check if we're in the right directory
if [ ! -f "$COMPOSE_FILE" ]; then
    error "❌ docker-compose.yml not found! Run this script from docker/dev directory."
fi

# Check if .env files exist
if [ ! -f "../../.env" ]; then
    warn "⚠️  .env file not found. Creating from .env.example if available..."
    if [ -f "../../.env.example" ]; then
        cp ../../.env.example ../../.env
        warn "📝 Please edit .env with your development values"
    else
        error "❌ No .env or .env.example found!"
    fi
fi

log "📋 Checking prerequisites..."
docker --version > /dev/null || error "Docker not installed"
docker-compose --version > /dev/null || error "Docker Compose not installed"

# Parse command line arguments
DETACHED=""
REBUILD=""
SERVICES=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--detached)
      DETACHED="-d"
      shift
      ;;
    -r|--rebuild)
      REBUILD="--build"
      shift
      ;;
    --app-only)
      SERVICES="app"
      shift
      ;;
    --worker-only)
      SERVICES="worker"
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  -d, --detached    Run in background"
      echo "  -r, --rebuild     Force rebuild images"
      echo "  --app-only        Start only the app service"
      echo "  --worker-only     Start only the worker service"
      echo "  -h, --help        Show this help"
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      ;;
  esac
done

if [ "$REBUILD" = "--build" ]; then
    log "🏗️  Rebuilding development images..."
    docker-compose -p $PROJECT_NAME build --no-cache $SERVICES
fi

log "🛑 Stopping any existing containers..."
docker-compose -p $PROJECT_NAME down --remove-orphans || warn "No existing containers to stop"

log "🚀 Starting development environment..."
if [ -n "$SERVICES" ]; then
    info "🎯 Starting only: $SERVICES"
fi

docker-compose -p $PROJECT_NAME up $REBUILD $DETACHED $SERVICES

if [ "$DETACHED" = "-d" ]; then
    log "✅ Development environment started in background!"
    echo ""
    info "🌐 App will be available at: http://localhost:3000"
    info "📊 Container status: docker-compose -p $PROJECT_NAME ps"
    info "📝 Follow logs: docker-compose -p $PROJECT_NAME logs -f"
    info "🛑 Stop: docker-compose -p $PROJECT_NAME down"
else
    log "🎉 Development environment started!"
    info "🌐 App is available at: http://localhost:3000"
    info "Press Ctrl+C to stop..."
fi