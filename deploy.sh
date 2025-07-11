#!/bin/bash
set -e

echo "🚀 Deploying FlowAI N8N Extension..."

# Check if required environment variables are set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN environment variable not set!"
    echo "Please set the GITHUB_TOKEN environment variable in Elestio dashboard"
    exit 1
fi

if [ -z "$GOOGLE_CREDENTIALS_JSON" ]; then
    echo "❌ Error: GOOGLE_CREDENTIALS_JSON environment variable not set!"
    echo "Please set the GOOGLE_CREDENTIALS_JSON environment variable in Elestio dashboard"
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