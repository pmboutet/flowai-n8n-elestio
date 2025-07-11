# Multi-stage build for better caching and smaller final image
FROM node:18-alpine AS builder

WORKDIR /app

# Install global build dependencies
RUN npm install -g typescript @babel/cli @babel/core @babel/preset-env @babel/preset-typescript

# Copy package files first for better caching
COPY package*.json ./

# Clear npm cache and install dependencies
RUN npm cache clean --force && npm install

# Copy source code
COPY . .

# Clean any existing build artifacts
RUN rm -rf lib/ && rm -rf dist/

# Compile the project
RUN npm run compile

# Final stage
FROM node:18-alpine

WORKDIR /app

# Copy package files and install production deps only
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy compiled code from builder
COPY --from=builder /app/lib ./lib
COPY --from=builder /app/index.js ./
COPY --from=builder /app/bin ./bin

# Create shared directory
RUN mkdir -p /app/shared

# Run as non-root user
USER node

# Start the application
CMD ["node", "index.js"]
