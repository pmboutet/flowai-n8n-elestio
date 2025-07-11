#!/bin/bash
set -e

# Load Elestio environment variables if available
if [ -f "/opt/app/.env" ]; then
    echo "🔧 Loading Elestio environment variables..."
    source /opt/app/.env
else
    echo "⚠️  Elestio .env file not found, using system environment variables"
fi

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

echo "✅ Environment variables loaded successfully"

# Create required directories
mkdir -p shared

echo "🔄 Pulling latest deployment configuration..."
echo "🗑️  Discarding local changes..."

# Force reset to latest remote version
git fetch origin master
git reset --hard origin/master

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