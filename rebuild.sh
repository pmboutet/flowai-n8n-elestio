#!/bin/bash

# Force rebuild all services without Docker cache
echo "🔥 Rebuilding all services without cache..."

# Stop and remove all containers
docker-compose down --volumes --remove-orphans

# Remove all images related to this project
echo "🗑️  Removing all project images..."
docker images | grep flowai | awk '{print $3}' | xargs -r docker rmi -f

# Remove dangling images
docker image prune -f

# Clear Docker build cache
echo "🧹 Clearing Docker build cache..."
docker builder prune -f

# Build without cache
echo "🔨 Building services without cache..."
docker-compose build --no-cache --parallel

# Start services
echo "🚀 Starting services..."
docker-compose up -d

echo "✅ Rebuild complete!"
