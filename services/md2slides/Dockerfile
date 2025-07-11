# Use Node.js 18 Alpine for smaller image
FROM node:18-alpine

WORKDIR /app

# Install the official md2gslides package globally
RUN npm install -g md2gslides@0.5.1

# Create directories for shared files
RUN mkdir -p /app/shared

# Copy server file
COPY server.js /app/

# Install server dependencies
RUN npm init -y && npm install express multer

# Run as non-root user
USER node

EXPOSE 3000

CMD ["node", "server.js"]
