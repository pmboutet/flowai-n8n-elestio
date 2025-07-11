#!/bin/bash
set -e

echo "🧪 Testing FlowAI deployment..."

# Test if required environment variables are set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN environment variable not set"
    exit 1
else
    echo "✅ GITHUB_TOKEN is set"
fi

if [ -z "$GOOGLE_CREDENTIALS_JSON" ]; then
    echo "❌ GOOGLE_CREDENTIALS_JSON environment variable not set"
    exit 1
else
    echo "✅ GOOGLE_CREDENTIALS_JSON is set"
fi

# Test if services are running
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Services are not running"
    exit 1
fi
echo "✅ Services are running"

# Test python-middleware endpoint
echo "🔍 Testing python-middleware..."
if curl -f -s http://localhost:8000/ > /dev/null; then
    echo "✅ Python middleware is responding"
else
    echo "❌ Python middleware is not responding"
    exit 1
fi

# Check if shared directory exists and is writable
echo "🔍 Testing shared volume..."
if [ -d "./shared" ] && [ -w "./shared" ]; then
    echo "✅ Shared volume is accessible"
else
    echo "❌ Shared volume issue"
    exit 1
fi

# Test that md2slides container is healthy
echo "🔍 Testing md2slides service..."
if docker-compose ps md2slides | grep -q "Up"; then
    echo "✅ md2slides service is running"
else
    echo "❌ md2slides service issue"
    exit 1
fi

echo "✅ All tests passed!"
echo "🎉 Your deployment is ready!"