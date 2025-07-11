#!/bin/bash

# Force rebuild all services without Docker cache
echo "🔥 Rebuilding all services without cache..."

# Stop and remove all containers
docker-compose down --volumes --remove-orphans

# Remove dangling images
docker image prune -f

# Build without cache
docker-compose build --no-cache --parallel

# Start services
docker-compose up -d

echo "✅ Rebuild complete!"
