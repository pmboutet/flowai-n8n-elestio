FROM node:18-alpine

WORKDIR /app

# Copy all files
COPY . .

# Install dependencies using existing package-lock.json
RUN npm install --only=production

# Create shared directory
RUN mkdir -p /app/shared

# Keep container running without executing index.js
CMD ["tail", "-f", "/dev/null"]