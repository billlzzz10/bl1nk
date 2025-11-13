#!/bin/bash

# bl1nkOS Services Initialization Script
# ติดตั้งและเริ่มต้น Redis และ Qdrant

set -e

echo "🚀 Starting bl1nkOS Services..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "❌ Error: Docker is not running. Please start Docker first."
  exit 1
fi

# Start services
echo "📦 Starting Redis and Qdrant..."
docker-compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
sleep 5

# Check Redis
echo "🔍 Checking Redis..."
if docker exec bl1nk-redis redis-cli ping | grep -q "PONG"; then
  echo "✅ Redis is ready"
else
  echo "❌ Redis failed to start"
  exit 1
fi

# Check Qdrant
echo "🔍 Checking Qdrant..."
if curl -s http://localhost:6333/healthz | grep -q "ok"; then
  echo "✅ Qdrant is ready"
else
  echo "❌ Qdrant failed to start"
  exit 1
fi

echo ""
echo "✨ All services are running!"
echo ""
echo "📊 Service URLs:"
echo "  - Redis: redis://localhost:6379"
echo "  - Qdrant HTTP: http://localhost:6333"
echo "  - Qdrant Dashboard: http://localhost:6333/dashboard"
echo ""
echo "🛠️  Next steps:"
echo "  1. Initialize Qdrant collections: node scripts/init-qdrant.js"
echo "  2. Start your application"
echo ""
