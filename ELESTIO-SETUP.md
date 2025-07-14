# FlowAI - Installation sur Elestio

Guide complet pour déployer FlowAI (N8N + Python Middleware + MD2Slides) sur Elestio.

## 📋 Prérequis

- Un serveur Elestio avec N8N installé
- Accès SSH au serveur
- Variables d'environnement configurées dans l'interface Elestio :
  - `GOOGLE_CREDENTIALS_JSON`
  - `GITHUB_TOKEN`

## 🚀 Installation rapide

### 1. Connexion et navigation

```bash
# Se connecter au serveur Elestio via SSH
# Aller dans le répertoire de l'application
cd /opt/app
```

### 2. Arrêter les services existants

```bash
docker-compose down
```

### 3. Créer la structure des services

```bash
# Créer les répertoires nécessaires
mkdir -p services/python-middleware services/md2slides shared
```

### 4. Cloner les services FlowAI

```bash
# Cloner le middleware Python
git clone https://github.com/pmboutet/flowai-python-middleware.git services/python-middleware

# Cloner le service MD2Slides
git clone https://github.com/pmboutet/md2googleslides.git services/md2slides
```

### 5. Mettre à jour le docker-compose

Ajouter ces services au fichier `docker-compose.yml` d'Elestio :

```yaml
# Ajouter à la fin du fichier docker-compose.yml
  # Middleware de PMB
  python-middleware:
    build: ./services/python-middleware
    ports:
      - "8000:8000"
    environment:
      - GOOGLE_CREDENTIALS_JSON=${GOOGLE_CREDENTIALS_JSON}
    volumes:
      - ./shared:/app/shared
    restart: unless-stopped

  # Service MD2Slides
  md2slides:
    build: ./services/md2slides
    ports:
      - "3000:3000"
    environment:
      - GITHUB_TOKEN=${GITHUB_TOKEN}
    volumes:
      - ./shared:/app/shared
    restart: unless-stopped
```

### 6. Valider et déployer

```bash
# Vérifier la configuration
docker-compose config

# Démarrer tous les services
docker-compose up -d
```

## 🔍 Vérification

### Statut des services

```bash
# Voir l'état de tous les conteneurs
docker-compose ps

# Résultat attendu :
# - postgres (healthy)
# - redis (healthy) 
# - n8n (running)
# - n8n-worker (running)
# - python-middleware (running)
# - md2slides (running)
```

### Test des endpoints

```bash
# Test du middleware Python
curl http://localhost:8000/health

# Test du service MD2Slides
curl http://localhost:3000/health

# Accès N8N via le domaine Elestio
# https://votre-domaine.elestio.app
```

### Logs de débogage

```bash
# Voir les logs de tous les services
docker-compose logs

# Logs d'un service spécifique
docker-compose logs python-middleware
docker-compose logs md2slides

# Suivre les logs en temps réel
docker-compose logs -f
```

## 🌐 Services disponibles

| Service | URL | Description |
|---------|-----|-------------|
| **N8N** | `https://votre-domaine.elestio.app` | Interface principale d'automatisation |
| **Python Middleware** | `http://localhost:8000` | API de traitement Python |
| **MD2Slides** | `http://localhost:3000` | Service de génération de slides |

## 🔧 Gestion quotidienne

### Redémarrer un service

```bash
# Redémarrer un service spécifique
docker-compose restart python-middleware
docker-compose restart md2slides

# Redémarrer tous les services
docker-compose restart
```

### Mettre à jour les services

```bash
# Aller dans le service à mettre à jour
cd services/python-middleware
git pull origin main
cd ../..

# Reconstruire et redémarrer
docker-compose up -d --build python-middleware
```

### Surveillance des ressources

```bash
# Voir l'utilisation des ressources
docker stats --no-stream

# Espace disque utilisé
du -sh services/ shared/
```

## 🛠️ Configuration avancée

### Variables d'environnement

Les variables sont configurées dans l'interface Elestio et automatiquement injectées :

- `GOOGLE_CREDENTIALS_JSON` : Clés Google API (format JSON)
- `GITHUB_TOKEN` : Token d'accès GitHub
- `DOMAIN` : Domaine Elestio (automatique)

### Partage de fichiers

Le répertoire `./shared` est monté dans tous les services :
- `/opt/app/shared` (hôte)
- `/app/shared` (conteneurs)

### Réseau Docker

Tous les services partagent le même réseau Docker. Dans N8N, utilisez :
- `http://python-middleware:8000` pour appeler le middleware
- `http://md2slides:3000` pour appeler le service slides

## 🚨 Dépannage

### Erreur "context path not found"

```bash
# Vérifier que les répertoires existent
ls -la services/

# Si manquants, les recréer
mkdir -p services/python-middleware services/md2slides
git clone https://github.com/pmboutet/flowai-python-middleware.git services/python-middleware
git clone https://github.com/pmboutet/md2googleslides.git services/md2slides
```

### Service qui ne démarre pas

```bash
# Voir les logs d'erreur
docker-compose logs service-en-erreur

# Forcer la reconstruction
docker-compose up -d --build --force-recreate service-en-erreur
```

### Problème de variables d'environnement

1. Vérifier dans l'interface Elestio que les variables sont bien définies
2. Redémarrer le stack complet : `docker-compose down && docker-compose up -d`

### Nettoyage complet

```bash
# Arrêter tous les services
docker-compose down --volumes

# Supprimer les images (optionnel)
docker system prune -f

# Relancer l'installation
docker-compose up -d
```

## 📚 Liens utiles

- [Repository principal](https://github.com/pmboutet/flowai-n8n-elestio)
- [Python Middleware](https://github.com/pmboutet/flowai-python-middleware)
- [MD2Slides Service](https://github.com/pmboutet/md2googleslides)
- [Documentation N8N](https://docs.n8n.io/)
- [Documentation Elestio](https://docs.elest.io/)

---

**✅ Installation terminée !** Vos services FlowAI sont maintenant intégrés à votre instance N8N sur Elestio.