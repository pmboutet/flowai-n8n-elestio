#!/bin/bash

# FlowAI - Installation rapide sur Elestio
# Usage: curl -sSL https://raw.githubusercontent.com/pmboutet/flowai-n8n-elestio/master/quick-install.sh | bash

set -e

echo "🚀 FlowAI - Installation rapide sur Elestio"
echo "==========================================="

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "docker-compose.yml" ]; then
    log_error "docker-compose.yml non trouvé. Êtes-vous dans /opt/app ?"
    exit 1
fi

log_info "Détection de l'environnement Elestio..."
log_success "✅ Fichier docker-compose.yml trouvé"

# Étape 1: Arrêter les services
log_info "1/6 - Arrêt des services existants..."
docker-compose down || log_warning "Certains services étaient déjà arrêtés"

# Étape 2: Créer la structure
log_info "2/6 - Création de la structure des répertoires..."
mkdir -p services/python-middleware services/md2slides shared
log_success "✅ Structure créée"

# Étape 3: Cloner les services
log_info "3/6 - Téléchargement des services FlowAI..."

if [ -d "services/python-middleware/.git" ]; then
    log_info "Mise à jour du Python Middleware..."
    cd services/python-middleware && git pull origin main && cd ../..
else
    log_info "Clonage du Python Middleware..."
    git clone https://github.com/pmboutet/flowai-python-middleware.git services/python-middleware
fi

if [ -d "services/md2slides/.git" ]; then
    log_info "Mise à jour du service MD2Slides..."
    cd services/md2slides && git pull origin main && cd ../..
else
    log_info "Clonage du service MD2Slides..."
    git clone https://github.com/pmboutet/md2googleslides.git services/md2slides
fi

log_success "✅ Services téléchargés"

# Étape 4: Vérifier les Dockerfiles
log_info "4/6 - Vérification des Dockerfiles..."
dockerfile_errors=0

if [ ! -f "services/python-middleware/Dockerfile" ]; then
    log_error "❌ Dockerfile manquant dans python-middleware"
    ((dockerfile_errors++))
else
    log_success "✅ Dockerfile python-middleware trouvé"
fi

if [ ! -f "services/md2slides/Dockerfile" ]; then
    log_error "❌ Dockerfile manquant dans md2slides"  
    ((dockerfile_errors++))
else
    log_success "✅ Dockerfile md2slides trouvé"
fi

if [ $dockerfile_errors -gt 0 ]; then
    log_error "Des Dockerfiles sont manquants. Vérifiez les repositories."
    exit 1
fi

# Étape 5: Valider la configuration
log_info "5/6 - Validation de la configuration Docker Compose..."
if docker-compose config > /dev/null 2>&1; then
    log_success "✅ Configuration Docker Compose valide"
else
    log_error "❌ Configuration Docker Compose invalide"
    log_info "Sortie de diagnostic:"
    docker-compose config
    exit 1
fi

# Étape 6: Démarrer les services
log_info "6/6 - Démarrage des services..."
docker-compose up -d

log_info "Attente du démarrage des services (60s)..."
sleep 60

# Vérification finale
log_info "🔍 Vérification finale..."
echo
echo "État des services:"
docker-compose ps
echo

# Test des endpoints
log_info "Test des endpoints FlowAI..."
test_errors=0

if curl -f -m 10 http://localhost:8000/health > /dev/null 2>&1; then
    log_success "✅ Python Middleware accessible (port 8000)"
else
    log_error "❌ Python Middleware non accessible"
    ((test_errors++))
fi

if curl -f -m 10 http://localhost:3000/health > /dev/null 2>&1; then
    log_success "✅ MD2Slides accessible (port 3000)"
else
    log_error "❌ MD2Slides non accessible"
    ((test_errors++))
fi

# Résumé final
echo
echo "🎉 INSTALLATION TERMINÉE"
echo "========================"
echo

if [ $test_errors -eq 0 ]; then
    log_success "✅ Tous les services FlowAI sont opérationnels!"
else
    log_warning "⚠️  Certains services ont des problèmes (voir ci-dessus)"
fi

echo
echo "📋 SERVICES DISPONIBLES"
echo "• N8N (interface): https://${DOMAIN:-[votre-domaine-elestio]}"
echo "• Python Middleware: http://localhost:8000"
echo "• MD2Slides: http://localhost:3000"
echo
echo "🔧 COMMANDES UTILES"
echo "• État: docker-compose ps"
echo "• Logs: docker-compose logs -f"
echo "• Restart: docker-compose restart [service]"
echo
echo "📁 RÉPERTOIRES"
echo "• Services: ./services/"
echo "• Fichiers partagés: ./shared/"
echo

if [ $test_errors -gt 0 ]; then
    echo "🚨 EN CAS DE PROBLÈME"
    echo "• Voir les logs: docker-compose logs [service-en-erreur]"
    echo "• Rebuilder: docker-compose up -d --build [service]"
    echo "• Support: https://github.com/pmboutet/flowai-n8n-elestio/issues"
fi

echo
log_success "🎯 FlowAI est maintenant intégré à votre N8N Elestio!"