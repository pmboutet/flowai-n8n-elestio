#!/bin/bash

# Clean deployment script - ensures fresh deployment from Git
echo "🚀 Starting clean deployment from Git..."

# Stop all services
echo "⏹️  Stopping all services..."
docker-compose down --volumes --remove-orphans

# Pull latest changes from Git
echo "📥 Pulling latest changes from Git..."
git pull origin master

# Remove all Docker images related to the project
echo "🗑️  Removing all project Docker images..."
docker images | grep flowai | awk '{print $3}' | xargs -r docker rmi -f

# Clear Docker builder cache
echo "🧹 Clearing Docker builder cache..."
docker builder prune -f --all

# Remove any dangling images
docker image prune -f

# Build fresh images without cache
echo "🔨 Building fresh images without cache..."
docker-compose build --no-cache --parallel

# Start services
echo "🚀 Starting services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service health
echo "🏥 Checking service health..."
docker-compose ps

# Test endpoints
echo "🧪 Testing service endpoints..."
curl -f http://localhost:3000/health && echo " ✅ md2slides is healthy" || echo " ❌ md2slides is not responding"
curl -f http://localhost:8000/health && echo " ✅ python-middleware is healthy" || echo " ❌ python-middleware is not responding"

echo "✅ Clean deployment complete!"
echo ""
echo "📝 Services:"
echo "  - md2slides: http://localhost:3000"
echo "  - python-middleware: http://localhost:8000"
