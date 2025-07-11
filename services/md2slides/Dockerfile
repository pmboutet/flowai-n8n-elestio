# Use the original Google md2gslides with a simple setup
FROM node:18-alpine

WORKDIR /app

# Install the original package globally
RUN npm install -g md2gslides

# Create directories for shared files
RUN mkdir -p /app/shared

# Simple server to handle requests via HTTP
COPY server.js /app/
RUN npm install express multer fs

# Run as non-root user
USER node

EXPOSE 3000

CMD ["node", "server.js"]
