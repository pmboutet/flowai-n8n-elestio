# FlowAI N8N Elestio Deployment

🚀 **v2.0 - Modernized with Security & Performance Enhancements**

This repository contains the deployment configuration for the FlowAI middleware and md2googleslides services with **major security and performance improvements**.

## ✨ What's New in v2.0

- 🔐 **Enhanced Security**: Updated md2googleslides with latest secure dependencies
- 🐳 **Optimized Docker**: Modern multi-stage builds and security best practices
- 📦 **Modern Dependencies**: Node.js 18+, latest Google APIs, vulnerability-free packages
- 🛡️ **Non-root Containers**: All services run with non-privileged users
- 🚀 **Better Performance**: Optimized builds and resource management
- 🔧 **Improved Reliability**: Comprehensive error handling and health checks

## Structure

```
flowai-n8n-elestio/
├── deploy.sh                          # Main deployment script
├── sync.sh                            # Service sync script (updated)
├── docker-compose.override.yml        # Docker services configuration (modernized)
├── services/                          # Service source code (synced from repos)
│   ├── python-middleware/             # FlowAI Python middleware
│   └── md2slides/                     # Modernized md2googleslides (NEW)
└── shared/                            # Shared volume data
```

## Environment Variables Required

Set these environment variables in your Elestio dashboard:

### 1. GitHub Token
- **Name:** `GITHUB_TOKEN`
- **Value:** Your GitHub personal access token (starts with `github_pat_`)

### 2. Google Credentials
- **Name:** `GOOGLE_CREDENTIALS_JSON`
- **Value:** Your complete Google service account JSON (the entire JSON content)

### How to set environment variables in Elestio:

1. Go to your Elestio dashboard
2. Select your service
3. Go to "Environment" tab
4. Add the variables:
   - `GITHUB_TOKEN`: `[Your GitHub token]`
   - `GOOGLE_CREDENTIALS_JSON`: `[Your complete Google service account JSON]`
5. Save and restart the service

## Quick Deployment

1. **Clone this repository on your server:**
   ```bash
   git clone https://github.com/pmboutet/flowai-n8n-elestio.git
   cd flowai-n8n-elestio
   ```

2. **Deploy (no manual file setup needed!):**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

## How it Works

The deployment script automatically:
1. ✅ Checks that required environment variables are set
2. 🔄 Pulls latest deployment configuration from Git
3. 📦 Syncs latest service code from the main repositories
4. 🛑 Stops existing services
5. 🏗️ Rebuilds and starts services with environment variables
6. ✅ Verifies deployment

**New in v2.0:** The sync process now pulls the **modernized, secure version** of md2googleslides with all security patches applied.

## Security Improvements

### md2googleslides Security Updates
- ✅ **Removed deprecated packages**: `request`, `request-promise-native`, `babel-polyfill`
- ✅ **Updated Google APIs**: Latest `google-auth-library` and `googleapis`
- ✅ **Fixed vulnerabilities**: All known security issues resolved
- ✅ **Modern Node.js**: Requires Node.js 18+ for latest security features
- ✅ **Non-root user**: Container runs as unprivileged user
- ✅ **Minimal attack surface**: Alpine Linux base with only required packages

### Infrastructure Security
- 🔒 **Secure credential handling**: Credentials injected via environment variables
- 🛡️ **Network isolation**: Services run in isolated Docker networks
- 📁 **Read-only volumes**: Source code mounted as read-only where possible
- 🔐 **Principle of least privilege**: Minimal container permissions

## Services

- **python-middleware:** Main API service (port 8000)
- **md2slides:** Modernized Google Slides generation service (port 3000)
  - 🔧 **New**: Now runs as a service with API endpoints
  - 🛡️ **Secure**: Latest dependencies with security fixes
  - 🚀 **Fast**: Optimized Docker build and runtime performance

Both services share the `./shared` volume for file exchange.

## Performance Enhancements

### Build Optimization
- 📦 **Multi-stage builds**: Smaller final images
- 🗜️ **Layer caching**: Faster rebuilds
- 🧹 **Clean installs**: Optimized dependency installation

### Runtime Optimization
- 💾 **Memory limits**: Configured resource constraints
- 🔄 **Health checks**: Automatic service monitoring
- ⚡ **Fast startup**: Optimized initialization sequence

## Making Changes

- **Infrastructure changes:** Modify files in this repository and commit
- **Code changes:** Make changes in the main middleware repository
- **Deploy updates:** Simply run `./deploy.sh` on the server

## Migration from v1.x

If you're upgrading from a previous version:

1. **Backup current deployment:**
   ```bash
   docker-compose down
   cp docker-compose.override.yml docker-compose.override.yml.backup
   ```

2. **Pull latest version:**
   ```bash
   git pull origin master
   ```

3. **Deploy with new version:**
   ```bash
   ./deploy.sh
   ```

The new version is **fully backward compatible** and will automatically use the modernized, secure components.

## Benefits of v2.0

✅ **No files to manage on server**  
✅ **Secure credential storage**  
✅ **Easy credential rotation**  
✅ **Fully Git-managed deployment**  
✅ **Zero manual configuration**  
✅ **Enhanced security posture**  
✅ **Better performance and reliability**  
✅ **Future-proof architecture**  

## Troubleshooting

Common errors and solutions:

1. **"GITHUB_TOKEN environment variable not set"**
   - Set the GitHub token in Elestio environment variables
   - Restart the service after adding variables

2. **"GOOGLE_CREDENTIALS_JSON environment variable not set"**
   - Set the complete Google service account JSON in Elestio
   - Make sure it's the full JSON content, not just a file path

3. **Authentication errors**
   - Verify your GitHub token has repo access
   - Verify your Google credentials are valid and have the right APIs enabled

4. **Build failures (NEW in v2.0)**
   - Check Docker logs: `docker-compose logs md2slides`
   - Verify Node.js version requirements are met
   - Ensure sufficient disk space for modern builds

5. **Service startup issues**
   - Check service status: `docker-compose ps`
   - View detailed logs: `docker-compose logs -f`
   - Verify environment variables are properly set

## API Endpoints (NEW)

The modernized md2slides service now exposes API endpoints:

- `GET /health` - Health check
- `POST /convert` - Convert markdown to Google Slides
- `GET /status` - Service status

Example usage:
```bash
# Health check
curl http://localhost:3000/health

# Convert markdown (from python-middleware)
curl -X POST http://localhost:3000/convert \
  -H "Content-Type: application/json" \
  -d '{"markdown": "# Hello\n\nWorld", "title": "My Slides"}'
```

## Support and Updates

- 🐛 **Issues**: Report on the main repositories
- 📖 **Documentation**: Check individual service READMEs
- 🔄 **Updates**: Run `./deploy.sh` to get latest versions automatically

---

**🎉 FlowAI v2.0 - More secure, more reliable, more powerful!**