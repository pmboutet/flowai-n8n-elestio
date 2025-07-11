# Deployment Scripts

This directory contains scripts to manage the FlowAI infrastructure deployment.

## Scripts

### clean-deploy.sh
Complete clean deployment from Git. This script:
- Stops all services
- Pulls latest code from Git
- Removes ALL Docker images and caches
- Builds fresh images without cache
- Starts services
- Verifies health

**Usage:**
```bash
chmod +x clean-deploy.sh
./clean-deploy.sh
```

### rebuild.sh
Rebuilds services without pulling from Git. Use this for local changes testing.
- Stops services
- Removes project images and caches
- Rebuilds without cache
- Starts services

**Usage:**
```bash
chmod +x rebuild.sh
./rebuild.sh
```

### deploy.sh
Standard deployment script (existing).

## Important Notes

1. **Always use clean-deploy.sh for production deployments** to ensure you're deploying the exact code from Git.

2. **md2slides service** now uses the official npm package (md2gslides@0.5.1) instead of building from source.

3. Services will be available at:
   - md2slides: http://localhost:3000
   - python-middleware: http://localhost:8000

4. Make sure to set the `GOOGLE_CREDENTIALS_JSON` environment variable for md2slides to work with Google APIs.
