#!/bin/bash

# Secure deployment script with credentials management
echo "🚀 FlowAI Secure Deployment"
echo "==========================="

# Source the credentials loader
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/load-credentials.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Function to check and free ports
check_and_free_ports() {
    log_info "🔍 Checking for port conflicts..."
    
    # Check port 3000
    if netstat -tuln 2>/dev/null | grep -q ":3000 "; then
        log_warning "Port 3000 is in use. Freeing it..."
        lsof -ti:3000 2>/dev/null | xargs -r kill -9
        sleep 2
    fi
    
    # Check port 8000
    if netstat -tuln 2>/dev/null | grep -q ":8000 "; then
        log_warning "Port 8000 is in use. Freeing it..."
        lsof -ti:8000 2>/dev/null | xargs -r kill -9
        sleep 2
    fi
    
    log_success "Ports 3000 and 8000 are now available"
}

# Function to validate environment
validate_environment() {
    log_info "🔍 Validating environment..."
    
    # Check if credentials are loaded
    if [ -z "$GITHUB_TOKEN" ] || [ -z "$GOOGLE_CREDENTIALS_JSON" ]; then
        log_error "Credentials not loaded properly"
        log_info "Run: source ./load-credentials.sh"
        return 1
    fi
    
    # Check Docker
    if ! command -v docker >/dev/null 2>&1; then
        log_error "Docker not installed"
        return 1
    fi
    
    if ! command -v docker-compose >/dev/null 2>&1; then
        log_error "Docker Compose not installed"
        return 1
    fi
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon not running"
        return 1
    fi
    
    log_success "Environment validation passed"
    return 0
}

# Function to prepare credentials directory
prepare_credentials() {
    log_info "📋 Preparing credentials..."
    
    local creds_dir="./credentials"
    
    # Ensure credentials directory exists
    mkdir -p "$creds_dir"
    
    # Create google-credentials.json from environment variable
    if [ -n "$GOOGLE_CREDENTIALS_JSON" ]; then
        echo "$GOOGLE_CREDENTIALS_JSON" > "$creds_dir/google-credentials.json"
        chmod 600 "$creds_dir/google-credentials.json"
        log_success "Google credentials file created"
    else
        log_error "GOOGLE_CREDENTIALS_JSON not available"
        return 1
    fi
    
    return 0
}

# Function to clean up old deployment
cleanup_old_deployment() {
    log_info "🧹 Cleaning up old deployment..."
    
    # Stop services
    docker-compose down --volumes --remove-orphans 2>/dev/null || true
    
    # Remove old images
    docker images | grep -E "flowai|md2slides|python-middleware" | awk '{print $3}' | xargs -r docker rmi -f
    
    # Clear builder cache
    docker builder prune -f --all
    
    log_success "Cleanup completed"
}

# Function to deploy services
deploy_services() {
    log_info "🚀 Deploying services..."
    
    # Ensure shared directory exists
    mkdir -p ./shared
    
    # Build and start services
    if docker-compose build --no-cache; then
        log_success "Build completed successfully"
    else
        log_error "Build failed"
        return 1
    fi
    
    if docker-compose up -d; then
        log_success "Services started successfully"
    else
        log_error "Failed to start services"
        docker-compose logs
        return 1
    fi
    
    return 0
}

# Function to test deployment
test_deployment() {
    log_info "🧪 Testing deployment..."
    
    # Wait for services to be ready
    log_info "Waiting for services to start (30 seconds)..."
    sleep 30
    
    # Test md2slides
    for i in {1..5}; do
        if curl -f -m 10 http://localhost:3000/health >/dev/null 2>&1; then
            log_success "md2slides: ✅ Healthy"
            break
        else
            if [ $i -eq 5 ]; then
                log_error "md2slides: ❌ Not responding"
                docker-compose logs md2slides | tail -10
                return 1
            else
                log_info "Attempt $i/5 - md2slides not ready yet..."
                sleep 10
            fi
        fi
    done
    
    # Test python-middleware
    for i in {1..5}; do
        if curl -f -m 10 http://localhost:8000/health >/dev/null 2>&1; then
            log_success "python-middleware: ✅ Healthy"
            break
        else
            if [ $i -eq 5 ]; then
                log_error "python-middleware: ❌ Not responding"
                docker-compose logs python-middleware | tail -10
                return 1
            else
                log_info "Attempt $i/5 - python-middleware not ready yet..."
                sleep 10
            fi
        fi
    done
    
    log_success "All health checks passed"
    return 0
}

# Function to show final status
show_status() {
    echo
    log_info "📊 Deployment Status"
    echo "===================="
    
    docker-compose ps
    
    echo
    log_info "🌐 Service Endpoints:"
    echo "  • md2slides: http://localhost:3000"
    echo "  • md2slides health: http://localhost:3000/health"
    echo "  • python-middleware: http://localhost:8000"
    echo "  • python-middleware health: http://localhost:8000/health"
    
    echo
    log_info "🔧 Management Commands:"
    echo "  • View logs: docker-compose logs -f"
    echo "  • Check status: docker-compose ps"
    echo "  • Restart: docker-compose restart"
    echo "  • Stop: docker-compose down"
    
    echo
    log_success "🎉 Secure deployment completed successfully!"
}

# Main deployment function
main() {
    local step_errors=0
    
    # Load credentials first
    if ! load_credentials; then
        log_error "Failed to load credentials"
        exit 1
    fi
    
    validate_environment || ((step_errors++))
    
    if [ $step_errors -eq 0 ]; then
        check_and_free_ports || ((step_errors++))
    fi
    
    if [ $step_errors -eq 0 ]; then
        prepare_credentials || ((step_errors++))
    fi
    
    if [ $step_errors -eq 0 ]; then
        cleanup_old_deployment || ((step_errors++))
    fi
    
    if [ $step_errors -eq 0 ]; then
        deploy_services || ((step_errors++))
    fi
    
    if [ $step_errors -eq 0 ]; then
        test_deployment || ((step_errors++))
    fi
    
    show_status
    
    if [ $step_errors -eq 0 ]; then
        exit 0
    else
        log_error "Deployment failed with $step_errors errors"
        exit 1
    fi
}

# Execute main function
main "$@"
