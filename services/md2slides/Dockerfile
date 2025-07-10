# Multi-stage build for smaller final image
FROM node:18-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN npm install -g typescript @babel/cli @babel/core @babel/preset-env @babel/preset-typescript

# Copy package files
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

# Compile the project
RUN npm run compile

# Final stage
FROM node:18-alpine

WORKDIR /app

# Copy package files and install production deps only
COPY package*.json ./
RUN npm ci --only=production

# Copy compiled code from builder
COPY --from=builder /app/lib ./lib
COPY --from=builder /app/index.js ./

# Create shared directory
RUN mkdir -p /app/shared

# Run as non-root user
USER node

# Start the application
CMD ["node", "index.js"]