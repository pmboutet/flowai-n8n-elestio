# Server Setup Instructions

Follow these steps to set up your server for Git-based deployments.

## 1. Initial Server Setup

```bash
# Connect to your server
ssh root@your-server-ip

# Update system
apt update && apt upgrade -y

# Install required packages
apt install -y git docker.io docker-compose curl rsync

# Start Docker
systemctl start docker
systemctl enable docker
```

## 2. Clone the Deployment Repository

```bash
# Remove existing directory if it exists
rm -rf /root/flowai-n8n-elestio

# Clone the deployment repository
cd /root
git clone https://github.com/pmboutet/flowai-n8n-elestio.git
cd flowai-n8n-elestio
```

## 3. Setup Credentials

```bash
# Create credentials directory
mkdir -p credentials

# Copy your Google service account credentials
# Replace this with your actual credentials file
cp /path/to/your/google-credentials.json credentials/google-credentials.json

# Verify credentials are in place
ls -la credentials/
```

## 4. Initial Deployment

```bash
# Make scripts executable
chmod +x *.sh

# Run initial deployment
./deploy.sh
```

## 5. Test the Deployment

```bash
# Run tests
./test.sh

# Check services
docker-compose ps

# Check logs if needed
docker-compose logs python-middleware
docker-compose logs md2slides
```

## 6. Future Deployments

For any future deployments, simply run:

```bash
cd /root/flowai-n8n-elestio
./deploy.sh
```

This will:
- Pull latest deployment configuration
- Sync latest code from the middleware repository
- Rebuild and restart services

## Troubleshooting

### Check service status
```bash
docker-compose ps
```

### View logs
```bash
docker-compose logs [service-name]
```

### Restart services
```bash
docker-compose restart
```

### Force rebuild
```bash
docker-compose down
docker-compose up -d --build --force-recreate
```