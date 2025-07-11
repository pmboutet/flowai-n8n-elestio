#!/bin/bash
set -e

# Load Elestio environment variables if available
if [ -f "/opt/app/.env" ]; then
    source /opt/app/.env
fi

echo "🔄 Syncing services from main repository..."

# Check if GitHub token is provided
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN environment variable not set!"
    echo "Please set the GITHUB_TOKEN environment variable in Elestio dashboard"
    exit 1
fi

MIDDLEWARE_REPO="https://pmboutet:${GITHUB_TOKEN}@github.com/pmboutet/flowai-python-middleware.git"
TMP_DIR="/tmp/flowai-sync"

# Clean up any existing temp directory
rm -rf $TMP_DIR

# Clone the middleware repository
echo "📥 Cloning middleware repository..."
git clone $MIDDLEWARE_REPO $TMP_DIR

# Sync python-middleware
echo "📦 Syncing python-middleware..."
rsync -av --delete $TMP_DIR/python-middleware/ ./services/python-middleware/

# Sync md2slides
echo "📦 Syncing md2slides..."
rsync -av --delete $TMP_DIR/md2slides/ ./services/md2slides/

# Clean up
rm -rf $TMP_DIR

echo "✅ Services synced successfully!"