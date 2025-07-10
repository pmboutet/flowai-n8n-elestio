FROM node:18-alpine

WORKDIR /app

# Install git
RUN apk add --no-cache git

# Clone md2googleslides repository
RUN git clone -b feature/auth0-support  https://github.com/pmboutet/md2googleslides.git .

# Install dependencies and compile
RUN npm install && npm run compile

# Create directories
RUN mkdir -p /app/shared
RUN mkdir -p /root/.md2googleslides

# Create a script to copy credentials at runtime
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'if [ -f /app/credentials.json ]; then' >> /start.sh && \
    echo '  cp /app/credentials.json /root/.md2googleslides/client_id.json' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo 'tail -f /dev/null' >> /start.sh && \
    chmod +x /start.sh

CMD ["/start.sh"]
