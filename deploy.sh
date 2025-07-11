#!/bin/bash
set -e

echo "🚀 Deploying FlowAI N8N Extension..."

# Check if credentials exist
if [ ! -f "credentials/google-credentials.json" ]; then
    echo "❌ Error: Google credentials not found!"
    echo "Please copy your service account JSON to credentials/google-credentials.json"
    exit 1
fi

# Create required directories
mkdir -p shared

echo "🔄 Pulling latest deployment configuration..."
git pull origin master

echo "🔄 Syncing latest services code..."
chmod +x sync.sh
./sync.sh

echo "🛑 Stopping existing services..."
docker-compose down

echo "🔨 Building and starting services..."
docker-compose up -d --build

echo "⏳ Waiting for services to start..."
sleep 10

echo "🔍 Checking service status..."
docker-compose ps

echo "✅ Deployment complete!"