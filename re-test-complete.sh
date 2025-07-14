#!/bin/bash

# Script de re-test complet pour FlowAI sur Elestio/n8n
set -e

echo "🔄 FlowAI v2.0 - Re-test complet sur Elestio"
echo "============================================="

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Vérification spécifique Elestio
check_elestio_environment() {
    log_info "Vérification de l'environnement Elestio..."
    
    # Vérifier si on est sur Elestio
    if [ -d "/opt/elestio" ] || grep -q "elestio" /etc/hostname 2>/dev/null; then
        log_success "Environnement Elestio détecté"
    else
        log_warning "Environnement Elestio non détecté (test possible quand même)"
    fi
    
    # Vérifier les variables via docker-compose config
    log_info "Vérification des variables d'environnement via Docker Compose..."
    
    if docker-compose config 2>/dev/null | grep -q "GOOGLE_CREDENTIALS_JSON"; then
        log_success "GOOGLE_CREDENTIALS_JSON configuré dans Docker Compose"
    else
        log_error "GOOGLE_CREDENTIALS_JSON non trouvé dans la configuration Docker"
        log_info "Assurez-vous que la variable est définie dans l'interface Elestio"
    fi
    
    # Pour GITHUB_TOKEN, vérifier s'il est accessible
    if [ -n "$GITHUB_TOKEN" ]; then
        log_success "GITHUB_TOKEN disponible (${GITHUB_TOKEN:0:10}...)"
    else
        log_warning "GITHUB_TOKEN non trouvé dans l'environnement shell"
        log_info "Vérifiez qu'il est défini dans l'interface d'administration Elestio"
    fi
    
    # Test de connectivité réseau
    test_network_connectivity
}

# Test de connectivité réseau
test_network_connectivity() {
    log_info "Test de connectivité réseau..."
    
    if ping -c 1 github.com > /dev/null 2>&1; then
        log_success "Connectivité GitHub: ✅"
    else
        log_error "Connectivité GitHub: ❌"
        return 1
    fi
    
    if ping -c 1 googleapis.com > /dev/null 2>&1; then
        log_success "Connectivité Google APIs: ✅"
    else
        log_error "Connectivité Google APIs: ❌"
        return 1
    fi
}

# Nettoyage adapté à Elestio
elestio_cleanup() {
    log_info "🧹 Nettoyage spécifique Elestio..."
    
    # Arrêter les services existants
    if docker-compose ps -q 2>/dev/null | grep -q .; then
        log_info "Arrêt des services Docker Compose..."
        docker-compose down --volumes --remove-orphans
    fi
    
    # Nettoyage Docker conservateur (pour ne pas affecter n8n principal)
    log_info "Nettoyage des images FlowAI uniquement..."
    docker images | grep -E "flowai|md2slides|python-middleware" | awk '{print $3}' | xargs -r docker rmi -f
    
    # Nettoyer les volumes liés au projet
    docker volume ls | grep flowai | awk '{print $2}' | xargs -r docker volume rm
    
    # Nettoyer les répertoires locaux seulement
    log_info "Suppression des répertoires du projet..."
    rm -rf services/ shared/
    
    log_success "Nettoyage Elestio terminé"
}

# Re-synchronisation des services - VERSION MISE À JOUR
sync_services() {
    log_info "📥 Synchronisation des services depuis GitHub..."
    
    # Créer la structure des répertoires
    mkdir -p services/python-middleware services/md2slides shared
    
    # Cloner/mettre à jour Python Middleware
    if [ -d "services/python-middleware/.git" ]; then
        log_info "Mise à jour du Python Middleware..."
        cd services/python-middleware && git pull origin main && cd ../..
    else
        log_info "Clonage du Python Middleware..."
        git clone https://github.com/pmboutet/flowai-python-middleware.git services/python-middleware
    fi
    
    # Cloner/mettre à jour MD2Slides
    if [ -d "services/md2slides/.git" ]; then
        log_info "Mise à jour du service MD2Slides..."
        cd services/md2slides && git pull origin main && cd ../..
    else
        log_info "Clonage du service MD2Slides..."
        git clone https://github.com/pmboutet/md2googleslides.git services/md2slides
    fi
    
    # Rendre les scripts exécutables
    chmod +x *.sh 2>/dev/null || true
    
    log_success "Synchronisation terminée"
}

# Validation adaptée à Elestio
elestio_validation() {
    log_info "🔍 Validation spécifique Elestio..."
    
    # Vérifier la structure des fichiers
    local errors=0
    
    # Vérifier les répertoires de services
    if [ -d "services/python-middleware" ] && [ -d "services/md2slides" ]; then
        log_success "Répertoires de services présents"
    else
        log_error "Certains répertoires de services manquent"
        ((errors++))
    fi
    
    # Vérifier les Dockerfiles
    if [ -f "services/python-middleware/Dockerfile" ]; then
        log_success "Dockerfile python-middleware présent"
    else
        log_error "Dockerfile python-middleware manquant"
        ((errors++))
    fi
    
    if [ -f "services/md2slides/Dockerfile" ]; then
        log_success "Dockerfile md2slides présent"
    else
        log_error "Dockerfile md2slides manquant"
        ((errors++))
    fi
    
    # Vérifier la syntaxe YAML si docker-compose existe
    if [ -f "docker-compose.yml" ]; then
        log_success "docker-compose.yml présent"
        
        # Vérifier la syntaxe YAML
        if docker-compose config > /dev/null 2>&1; then
            log_success "Configuration Docker Compose valide"
        else
            log_error "Configuration Docker Compose invalide"
            ((errors++))
        fi
    else
        log_warning "docker-compose.yml non trouvé (normal pour repository principal)"
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "Validation Elestio réussie"
        return 0
    else
        log_error "Validation Elestio échouée ($errors erreurs)"
        return 1
    fi
}

# Déploiement sur Elestio
elestio_deploy() {
    log_info "🚀 Déploiement sur Elestio..."
    
    # Vérifier qu'on est dans le bon environnement
    if [ ! -f "docker-compose.yml" ]; then
        log_error "docker-compose.yml non trouvé. Êtes-vous dans /opt/app sur Elestio ?"
        return 1
    fi
    
    # Créer le répertoire shared s'il n'existe pas
    mkdir -p ./shared
    
    # Déployer les services
    log_info "Construction et démarrage des services..."
    docker-compose up -d --build python-middleware md2slides
    
    log_success "Déploiement lancé"
}

# Tests post-déploiement sur Elestio
elestio_post_tests() {
    log_info "🧪 Tests post-déploiement Elestio..."
    
    # Attendre que les services soient prêts
    log_info "Attente de la disponibilité des services (45s)..."
    sleep 45
    
    # Vérifier les conteneurs
    log_info "État des conteneurs:"
    docker-compose ps
    
    # Test des endpoints
    local test_errors=0
    
    # Test md2slides
    if curl -f -m 10 http://localhost:3000/health > /dev/null 2>&1; then
        log_success "md2slides: ✅ Service accessible"
    else
        log_error "md2slides: ❌ Service non accessible"
        ((test_errors++))
    fi
    
    # Test python-middleware
    if curl -f -m 10 http://localhost:8000/health > /dev/null 2>&1; then
        log_success "python-middleware: ✅ Service accessible"
    else
        log_error "python-middleware: ❌ Service non accessible"
        ((test_errors++))
    fi
    
    # Vérifier les logs pour les erreurs
    log_info "Vérification des logs pour les erreurs critiques..."
    if docker-compose logs | grep -i "error\|fatal\|exception" | head -5; then
        log_warning "Erreurs détectées dans les logs (voir ci-dessus)"
    else
        log_success "Aucune erreur critique dans les logs"
    fi
    
    if [ $test_errors -eq 0 ]; then
        log_success "Tous les tests post-déploiement réussis"
        return 0
    else
        log_error "$test_errors tests ont échoué"
        return 1
    fi
}

# Rapport final pour Elestio
elestio_final_report() {
    echo
    echo "📊 RAPPORT FINAL ELESTIO"
    echo "========================"
    echo
    
    log_info "Services Docker Compose:"
    docker-compose ps
    
    echo
    log_info "Utilisation des ressources:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
    
    echo
    log_info "Endpoints disponibles:"
    echo "  • md2slides: http://localhost:3000"
    echo "  • md2slides health: http://localhost:3000/health"
    echo "  • python-middleware: http://localhost:8000"
    echo "  • python-middleware health: http://localhost:8000/health"
    
    echo
    log_info "Commandes de monitoring:"
    echo "  • Logs en temps réel: docker-compose logs -f"
    echo "  • Status services: docker-compose ps"
    echo "  • Redémarrage: docker-compose restart"
    echo "  • Arrêt propre: docker-compose down"
    
    echo
    log_info "Fichiers partagés:"
    if [ -d "./shared" ]; then
        echo "  • Répertoire shared: $(du -sh ./shared 2>/dev/null || echo 'Vide')"
        ls -la ./shared/ 2>/dev/null | head -5
    fi
    
    echo
    log_success "🎉 Re-test Elestio terminé!"
    echo
    log_info "💡 Si vous rencontrez des problèmes:"
    echo "  1. Vérifiez les variables d'environnement dans l'interface Elestio"
    echo "  2. Consultez les logs: docker-compose logs"
    echo "  3. Relancez le test: ./re-test-complete.sh full"
}

# Test complet pour Elestio
elestio_full_test() {
    log_info "🎯 Test complet FlowAI sur Elestio..."
    
    local step_errors=0
    
    check_elestio_environment || ((step_errors++))
    echo
    
    if [ $step_errors -eq 0 ]; then
        elestio_cleanup || ((step_errors++))
        echo
    fi
    
    if [ $step_errors -eq 0 ]; then
        sync_services || ((step_errors++))
        echo
    fi
    
    if [ $step_errors -eq 0 ]; then
        elestio_validation || ((step_errors++))
        echo
    fi
    
    if [ $step_errors -eq 0 ]; then
        elestio_deploy || ((step_errors++))
        echo
    fi
    
    if [ $step_errors -eq 0 ]; then
        elestio_post_tests || ((step_errors++))
        echo
    fi
    
    elestio_final_report
    
    if [ $step_errors -eq 0 ]; then
        log_success "✅ Test complet Elestio réussi!"
        return 0
    else
        log_error "❌ Test complet Elestio échoué ($step_errors erreurs)"
        return 1
    fi
}

# Menu principal
show_menu() {
    echo
    echo "FlowAI v2.0 - Re-test sur Elestio"
    echo "=================================="
    echo "1) Test complet Elestio (recommandé)"
    echo "2) Vérification environnement seulement"
    echo "3) Nettoyage seulement"
    echo "4) Synchronisation services seulement"
    echo "5) Validation seulement"
    echo "6) Déploiement seulement"
    echo "7) Tests post-déploiement seulement"
    echo "8) Rapport final seulement"
    echo "9) Quitter"
    echo
    read -p "Votre choix [1-9]: " choice
    
    case $choice in
        1) elestio_full_test ;;
        2) check_elestio_environment ;;
        3) elestio_cleanup ;;
        4) sync_services ;;
        5) elestio_validation ;;
        6) elestio_deploy ;;
        7) elestio_post_tests ;;
        8) elestio_final_report ;;
        9) log_info "Au revoir!"; exit 0 ;;
        *) log_error "Option invalide"; show_menu ;;
    esac
}

# Point d'entrée
main() {
    if [ $# -eq 0 ]; then
        show_menu
    else
        case $1 in
            "full") elestio_full_test ;;
            "env") check_elestio_environment ;;
            "clean") elestio_cleanup ;;
            "sync") sync_services ;;
            "validate") elestio_validation ;;
            "deploy") elestio_deploy ;;
            "test") elestio_post_tests ;;
            "report") elestio_final_report ;;
            *)
                echo "Usage: $0 [full|env|clean|sync|validate|deploy|test|report]"
                echo "Ou exécutez sans argument pour le menu interactif"
                exit 1
                ;;
        esac
    fi
}

main "$@"