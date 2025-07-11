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
MD2SLIDES_REPO="https://pmboutet:${GITHUB_TOKEN}@github.com/pmboutet/md2googleslides.git"
TMP_DIR="/tmp/flowai-sync"

# Clean up any existing temp directory
rm -rf $TMP_DIR

# Clone the middleware repository
echo "📥 Cloning middleware repository..."
git clone $MIDDLEWARE_REPO $TMP_DIR/middleware

# Clone the updated md2googleslides repository
echo "📥 Cloning updated md2googleslides repository..."
git clone $MD2SLIDES_REPO $TMP_DIR/md2slides

# Sync python-middleware
echo "📦 Syncing python-middleware..."
rsync -av --delete $TMP_DIR/middleware/python-middleware/ ./services/python-middleware/

# Sync md2slides with the new modernized version
echo "📦 Syncing md2googleslides (modernized version)..."
# Create services directory if it doesn't exist
mkdir -p ./services/md2slides

# Copy the entire updated md2googleslides project
rsync -av --delete $TMP_DIR/md2slides/ ./services/md2slides/

# Create a simple wrapper Dockerfile for the service if it doesn't exist
if [ ! -f "./services/md2slides/Dockerfile.service" ]; then
    echo "🐳 Creating service wrapper Dockerfile..."
    cat > ./services/md2slides/Dockerfile.service << 'EOF'
# Use the modernized md2googleslides base
FROM node:20-alpine

# Install system dependencies for Sharp and other native tools
RUN apk add --no-cache \
    g++ \
    make \
    python3 \
    py3-pip \
    vips-dev \
    libc6-compat \
    pkgconfig \
    pixman-dev \
    cairo-dev \
    pango-dev \
    libjpeg-turbo-dev \
    giflib-dev

# Create app user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S md2slides -u 1001

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy source code
COPY . .

# Compile TypeScript
RUN npm run compile

# Change ownership to non-root user
RUN chown -R md2slides:nodejs /app
USER md2slides

# Create directory for Google credentials
RUN mkdir -p /home/md2slides/.md2googleslides

# Environment variables
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=2048"

# Expose port for service communication
EXPOSE 3000

# Service entry point
CMD ["node", "bin/md2gslides.js", "--help"]
EOF
fi

# Clean up
rm -rf $TMP_DIR

echo "✅ Services synced successfully!"
echo "🔧 Updated md2googleslides to modern, secure version with:"
echo "   ✅ Latest dependencies (Node.js 18+)"
echo "   ✅ Security fixes applied"
echo "   ✅ Docker optimization"
echo "   ✅ TypeScript compilation fixes"