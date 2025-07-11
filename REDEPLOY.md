# FlowAI v2.0 - Complete Redeploy Guide

## 🔥 Clean Installation (Recommended)

Since you're the only user, the easiest approach is a clean redeploy with the modernized version.

### 1. Stop and Clean Everything

```bash
# Stop all services
docker-compose down

# Remove old containers and images
docker system prune -af

# Clean service directories
rm -rf services/
rm -rf shared/
```

### 2. Deploy v2.0

```bash
# Pull latest configuration
git pull origin master

# Validate environment (optional)
chmod +x validate.sh
./validate.sh

# Clean deploy
chmod +x deploy.sh
./deploy.sh
```

That's it! The deploy script will:
- ✅ Sync the modernized md2googleslides automatically
- ✅ Build with latest security patches
- ✅ Configure optimized Docker setup
- ✅ Start services with proper credentials

### 3. Verify Deployment

```bash
# Check services
docker-compose ps

# Test md2slides health
curl http://localhost:3000/health

# Check logs
docker-compose logs -f
```

## 🎯 What You Get

- 🔐 **Secure md2googleslides**: All vulnerabilities patched
- 🚀 **Better performance**: Modern Node.js 18+ and optimized builds
- 🛡️ **Enhanced security**: Non-root containers and latest dependencies
- 📦 **Simplified maintenance**: Auto-sync from modernized repository

## 💡 Environment Variables

Make sure these are set in Elestio:
- `GITHUB_TOKEN`: Your GitHub personal access token
- `GOOGLE_CREDENTIALS_JSON`: Your complete Google service account JSON

## 🚨 If Issues Occur

```bash
# Nuclear option - start completely fresh
docker-compose down
docker system prune -af
git reset --hard origin/master
./deploy.sh
```

That's the beauty of the new v2.0 - everything is automated and pulls the secure, modernized components automatically! 🎉