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

## 🚀 Quick Deploy (Clean Installation)

For the cleanest experience with v2.0:

```bash
# 1. Clone and navigate
git clone https://github.com/pmboutet/flowai-n8n-elestio.git
cd flowai-n8n-elestio

# 2. Set environment variables in Elestio dashboard:
#    - GITHUB_TOKEN: Your GitHub personal access token
#    - GOOGLE_CREDENTIALS_JSON: Your complete Google service account JSON

# 3. Deploy
chmod +x deploy.sh
./deploy.sh
```

**That's it!** The system will automatically pull the modernized, secure md2googleslides and deploy everything.

## 📋 Environment Variables Required

Set these in your Elestio dashboard:

| Variable | Description |
|----------|-------------|
| `GITHUB_TOKEN` | Your GitHub personal access token (starts with `github_pat_`) |
| `GOOGLE_CREDENTIALS_JSON` | Complete Google service account JSON (the entire JSON content) |

## 🔄 Updating Existing Installation

If you already have FlowAI deployed, see **[REDEPLOY.md](REDEPLOY.md)** for the simple update process.

## 🏗️ Architecture

```
flowai-n8n-elestio/
├── deploy.sh                    # Main deployment script
├── sync.sh                      # Pulls modernized md2googleslides automatically
├── docker-compose.override.yml  # Optimized container configuration
├── validate.sh                  # Pre-deployment validation
├── services/                    # Auto-synced service code
│   ├── python-middleware/       # FlowAI Python middleware
│   └── md2slides/              # Modernized md2googleslides (auto-synced)
└── shared/                     # Shared data volume
```

## 🔧 Services

- **python-middleware** (port 8000): Main FlowAI API service
- **md2slides** (port 3000): Modernized Google Slides generation service
  - 🆕 **API mode**: Now runs as a service with REST endpoints
  - 🔐 **Secure**: Latest dependencies with all security patches
  - 🚀 **Fast**: Optimized performance and startup time

## 🎯 Key Benefits

✅ **Zero manual configuration** - Everything is automated  
✅ **Always up-to-date** - Auto-pulls latest secure versions  
✅ **Enhanced security** - All vulnerabilities patched  
✅ **Better performance** - Modern, optimized stack  
✅ **Simple maintenance** - One command deploys everything  

## 🧪 Testing & Validation

Optional validation before deployment:
```bash
chmod +x validate.sh
./validate.sh
```

Test services after deployment:
```bash
# Health checks
curl http://localhost:3000/health    # md2slides
curl http://localhost:8000/health    # python-middleware

# Service status
docker-compose ps
docker-compose logs -f
```

## 🆘 Support

- 🔥 **Quick fix**: See [REDEPLOY.md](REDEPLOY.md) for clean reinstall
- 🧪 **Diagnostics**: Run `./validate.sh` to check configuration
- 📋 **Logs**: Use `docker-compose logs -f` for real-time debugging
- 🐛 **Issues**: Report on the main repositories

## 🔒 Security Features

- 🛡️ **Non-root containers**: All services run as unprivileged users
- 🔐 **Secure credential handling**: Environment-based secrets management  
- 📦 **Minimal attack surface**: Alpine Linux with only required packages
- 🔄 **Regular updates**: Auto-sync ensures latest security patches
- 🚫 **No persistent secrets**: Credentials injected at runtime only

---

**🎉 FlowAI v2.0 - Secure, Fast, Simple!**

For clean deployment → Run `./deploy.sh`  
For updates → See [REDEPLOY.md](REDEPLOY.md)