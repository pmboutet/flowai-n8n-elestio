#!/bin/bash
set -e

echo "🚀 Deploying FlowAI N8N Extension..."

if [ ! -f "credentials/google-credentials.json" ]; then
    echo "❌ Error: Google credentials not found!"
    echo "Please copy your service account JSON to credentials/google-credentials.json"
    exit 1
fi

mkdir -p shared

echo "🛑 Stopping existing services..."
docker-compose down

echo "🔨 Building and starting services..."
docker-compose up -d --build

echo "⏳ Waiting for services to start..."
sleep 10

echo "🔍 Checking service status..."
docker-compose ps

echo "✅ Deployment complete!"
