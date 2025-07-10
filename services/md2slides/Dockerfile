FROM node:18-alpine

WORKDIR /app

# Install build dependencies including TypeScript
RUN npm install -g typescript @babel/cli @babel/core @babel/preset-env @babel/preset-typescript

# Copy package files first
COPY package*.json ./

# Install all dependencies (including dev deps for building)
RUN npm install

# Copy source code
COPY . .

# Compile the project
RUN npm run compile

# Create shared directory
RUN mkdir -p /app/shared

# Keep container running
CMD ["tail", "-f", "/dev/null"]