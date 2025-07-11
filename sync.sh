#!/bin/bash
set -e

echo "🔄 Syncing services from main repository..."

MIDDLEWARE_REPO="https://github.com/pmboutet/flowai-python-middleware.git"
TMP_DIR="/tmp/flowai-sync"

# Clean up any existing temp directory
rm -rf $TMP_DIR

# Clone the middleware repository
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