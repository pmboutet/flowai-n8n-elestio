# FlowAI N8N Elestio Deployment

🚀 **v2.0 - Modernized with Security & Performance Enhancements**

This repository contains the deployment configuration for the FlowAI middleware and md2googleslides services with **major security and performance improvements**.

## ✨ What's New in v2.0

- 🔒 **Enhanced Security**: Updated md2googleslides with latest secure dependencies
- 🏗️ **Optimized Docker**: Modern multi-stage builds and security best practices
- 📦 **Modern Dependencies**: Node.js 18+, latest Google APIs, vulnerability-free packages
- 👤 **Non-root Containers**: All services run with non-privileged users
- 🚀 **Better Performance**: Optimized builds and resource management
- 🛡️ **Improved Reliability**: Comprehensive error handling and health checks

## 🎯 **Installation rapide (Méthode validée)**

### Option 1: Installation automatique

```bash
# Dans votre serveur Elestio, répertoire /opt/app
curl -sSL https://raw.githubusercontent.com/pmboutet/flowai-n8n-elestio/master/quick-install.sh | bash
```

### Option 2: Installation manuelle

```bash
# 1. Navigation
cd /opt/app

# 2. Arrêter les services
docker-compose down

# 3. Créer la structure
mkdir -p services/python-middleware services/md2slides shared

# 4. Cloner les services
git clone https://github.com/pmboutet/flowai-python-middleware.git services/python-middleware
git clone https://github.com/pmboutet/md2googleslides.git services/md2slides

# 5. Ajouter au docker-compose.yml d'Elestio :
#   - python-middleware (port 8000)
#   - md2slides (port 3000)

# 6. Valider et déployer
docker-compose config
docker-compose up -d
```

**Documentation complète :** [ELESTIO-SETUP.md](ELESTIO-SETUP.md)

## 📋 Variables d'environnement requises

Configurez dans l'interface Elestio :

| Variable | Description |
|----------|-------------|
| `GITHUB_TOKEN` | Votre GitHub personal access token (starts with `github_pat_`) |
| `GOOGLE_CREDENTIALS_JSON` | Complete Google service account JSON (the entire JSON content) |

## 🏗️ Architecture

```
flowai-n8n-elestio/
├── ELESTIO-SETUP.md                  # Guide d'installation détaillé
├── quick-install.sh                  # Installation automatique
├── re-test-complete.sh               # Script de test complet
├── docker-compose.override.yml       # Configuration optimisée
├── services/                         # Services auto-synchronisés
│   ├── python-middleware/            # FlowAI Python middleware
│   └── md2slides/                    # Service de génération de slides
└── shared/                           # Volume de données partagé
```

## 🛡️ Services

- **python-middleware** (port 8000): Main FlowAI API service
- **md2slides** (port 3000): Modernized Google Slides generation service
  - 🆕 **API mode**: Now runs as a service with REST endpoints
  - 🔒 **Secure**: Latest dependencies with all security patches
  - 🚀 **Fast**: Optimized performance and startup time

## 🌐 Endpoints disponibles

| Service | URL | Description |
|---------|-----|-------------|
| **N8N** | `https://votre-domaine.elestio.app` | Interface principale |
| **Python Middleware** | `http://localhost:8000` | API Python |
| **MD2Slides** | `http://localhost:3000` | Génération de slides |

## 🎯 Avantages clés

✅ **Zero manual configuration** - Everything is automated  
✅ **Always up-to-date** - Auto-pulls latest secure versions  
✅ **Enhanced security** - All vulnerabilities patched  
✅ **Better performance** - Modern, optimized stack  
✅ **Simple maintenance** - One command deploys everything  

## 🧪 Testing & Validation

Test services after deployment:
```bash
# Health checks
curl http://localhost:3000/health     # md2slides
curl http://localhost:8000/health     # python-middleware

# Service status
docker-compose ps
docker-compose logs -f
```

Optional validation before deployment:
```bash
chmod +x re-test-complete.sh
./re-test-complete.sh full
```

## 🆘 Support

- 🔧 **Installation**: Voir [ELESTIO-SETUP.md](ELESTIO-SETUP.md)
- 🧪 **Diagnostics**: Run `./re-test-complete.sh` to check configuration
- 📋 **Logs**: Use `docker-compose logs -f` for real-time debugging
- 🐛 **Issues**: Report on the main repositories

## 🔒 Security Features

- 👤 **Non-root containers**: All services run as unprivileged users
- 🔒 **Secure credential handling**: Environment-based secrets management  
- 📦 **Minimal attack surface**: Alpine Linux with only required packages
- 🔄 **Regular updates**: Auto-sync ensures latest security patches
- 🚫 **No persistent secrets**: Credentials injected at runtime only

## 🚀 Quick Commands

```bash
# Status
docker-compose ps

# Restart service
docker-compose restart python-middleware

# Update service
cd services/python-middleware && git pull && cd ../..
docker-compose up -d --build python-middleware

# View logs
docker-compose logs -f md2slides
```

---

**🎉 FlowAI v2.0 - Secure, Fast, Simple!**

For clean deployment ➜ Run `./quick-install.sh` or see [ELESTIO-SETUP.md](ELESTIO-SETUP.md)