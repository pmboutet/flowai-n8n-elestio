FROM node:18-alpine

WORKDIR /app

# Copy all files
COPY . .

# Install dependencies without running scripts (avoids TypeScript compilation)
RUN npm install --only=production --ignore-scripts

# Create shared directory
RUN mkdir -p /app/shared

# Keep container running without executing index.js
CMD ["tail", "-f", "/dev/null"]