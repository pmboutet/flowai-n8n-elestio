#!/bin/bash
set -e

echo "🧪 Testing FlowAI deployment..."

# Test if services are running
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Services are not running"
    exit 1
fi

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

echo "✅ All tests passed!"