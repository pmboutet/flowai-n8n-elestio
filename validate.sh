#!/bin/bash

# FlowAI v2.0 Validation and Testing Script
set -e

echo "🧪 FlowAI v2.0 - Validation & Testing Suite"
echo "=========================================="

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

# Test environment variables
test_environment() {
    log_info "Testing environment variables..."
    
    if [ -z "$GITHUB_TOKEN" ]; then
        log_error "GITHUB_TOKEN not set"
        return 1
    else
        log_success "GITHUB_TOKEN is configured"
    fi
    
    if [ -z "$GOOGLE_CREDENTIALS_JSON" ]; then
        log_error "GOOGLE_CREDENTIALS_JSON not set"
        return 1
    else
        log_success "GOOGLE_CREDENTIALS_JSON is configured"
        # Validate JSON format
        if echo "$GOOGLE_CREDENTIALS_JSON" | jq . >/dev/null 2>&1; then
            log_success "GOOGLE_CREDENTIALS_JSON is valid JSON"
        else
            log_error "GOOGLE_CREDENTIALS_JSON is not valid JSON"
            return 1
        fi
    fi
}

# Test service sync
test_sync() {
    log_info "Testing service synchronization..."
    
    if [ -x "./sync.sh" ]; then
        log_success "sync.sh is executable"
        
        # Run sync in test mode if possible
        log_info "Running sync process..."
        if ./sync.sh; then
            log_success "Service sync completed successfully"
        else
            log_error "Service sync failed"
            return 1
        fi
    else
        log_error "sync.sh not found or not executable"
        return 1
    fi
}

# Test Docker Compose configuration
test_docker_compose() {
    log_info "Testing Docker Compose configuration..."
    
    if [ -f "docker-compose.override.yml" ]; then
        log_success "docker-compose.override.yml found"
        
        # Validate YAML syntax
        if docker-compose config >/dev/null 2>&1; then
            log_success "Docker Compose configuration is valid"
        else
            log_error "Docker Compose configuration is invalid"
            return 1
        fi
    else
        log_error "docker-compose.override.yml not found"
        return 1
    fi
}

# Test services structure
test_services_structure() {
    log_info "Testing services structure..."
    
    if [ -d "./services" ]; then
        log_success "Services directory exists"
        
        if [ -d "./services/md2slides" ]; then
            log_success "md2slides service directory exists"
            
            # Check for required files
            if [ -f "./services/md2slides/package.json" ]; then
                log_success "md2slides package.json found"
                
                # Check if it's the modernized version
                if grep -q "md2gslides" "./services/md2slides/package.json" && grep -q "0.5.2" "./services/md2slides/package.json"; then
                    log_success "md2slides is using modernized version (v0.5.2)"
                else
                    log_warning "md2slides might not be using the latest modernized version"
                fi
            else
                log_warning "md2slides package.json not found (will be synced on deployment)"
            fi
            
            if [ -f "./services/md2slides/Dockerfile" ]; then
                log_success "md2slides Dockerfile found"
            else
                log_warning "md2slides Dockerfile not found (will be synced on deployment)"
            fi
        else
            log_warning "md2slides service directory not found (will be created on sync)"
        fi
        
        if [ -d "./services/python-middleware" ]; then
            log_success "python-middleware service directory exists"
        else
            log_warning "python-middleware service directory not found (will be synced on deployment)"
        fi
    else
        log_warning "Services directory not found (will be created on sync)"
    fi
}

# Test shared directory
test_shared_directory() {
    log_info "Testing shared directory..."
    
    if [ -d "./shared" ]; then
        log_success "Shared directory exists"
    else
        log_info "Creating shared directory..."
        mkdir -p ./shared
        log_success "Shared directory created"
    fi
}

# Test Docker availability
test_docker() {
    log_info "Testing Docker availability..."
    
    if command -v docker >/dev/null 2>&1; then
        log_success "Docker is installed"
        
        if docker info >/dev/null 2>&1; then
            log_success "Docker daemon is running"
        else
            log_error "Docker daemon is not running"
            return 1
        fi
    else
        log_error "Docker is not installed"
        return 1
    fi
    
    if command -v docker-compose >/dev/null 2>&1; then
        log_success "Docker Compose is installed"
    else
        log_error "Docker Compose is not installed"
        return 1
    fi
}

# Test network connectivity
test_connectivity() {
    log_info "Testing network connectivity..."
    
    if ping -c 1 github.com >/dev/null 2>&1; then
        log_success "GitHub connectivity OK"
    else
        log_error "Cannot reach GitHub"
        return 1
    fi
    
    if ping -c 1 googleapis.com >/dev/null 2>&1; then
        log_success "Google APIs connectivity OK"
    else
        log_error "Cannot reach Google APIs"
        return 1
    fi
}

# Test deployment readiness
test_deployment_readiness() {
    log_info "Testing deployment readiness..."
    
    local errors=0
    
    # Check if deploy.sh exists and is executable
    if [ -x "./deploy.sh" ]; then
        log_success "deploy.sh is ready"
    else
        log_error "deploy.sh not found or not executable"
        ((errors++))
    fi
    
    # Check if we have write permissions
    if [ -w "." ]; then
        log_success "Directory is writable"
    else
        log_error "Directory is not writable"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "Deployment readiness check passed"
        return 0
    else
        log_error "Deployment readiness check failed ($errors errors)"
        return 1
    fi
}

# Security validation
test_security() {
    log_info "Running security validations..."
    
    # Check if credentials will be properly secured
    if echo "$GOOGLE_CREDENTIALS_JSON" | grep -q "private_key"; then
        log_success "Google credentials contain private key (looks valid)"
    else
        log_warning "Google credentials might not contain a private key"
    fi
    
    # Check for any exposed secrets in files
    if find . -name "*.json" -exec grep -l "private_key" {} \; | grep -v ".git" >/dev/null 2>&1; then
        log_error "Found potential credentials in files! Please remove them."
        find . -name "*.json" -exec grep -l "private_key" {} \; | grep -v ".git"
        return 1
    else
        log_success "No exposed credentials found in files"
    fi
}

# Main test runner
run_all_tests() {
    local failed_tests=0
    local total_tests=8
    
    echo
    log_info "Running comprehensive validation suite..."
    echo
    
    # Run all tests
    test_environment || ((failed_tests++))
    echo
    test_docker || ((failed_tests++))
    echo
    test_connectivity || ((failed_tests++))
    echo
    test_security || ((failed_tests++))
    echo
    test_docker_compose || ((failed_tests++))
    echo
    test_shared_directory || ((failed_tests++))
    echo
    test_services_structure || ((failed_tests++))
    echo
    test_sync || ((failed_tests++))
    echo
    test_deployment_readiness || ((failed_tests++))
    
    echo
    echo "=========================================="
    if [ $failed_tests -eq 0 ]; then
        log_success "🎉 All tests passed! ($total_tests/$total_tests)"
        log_success "✅ FlowAI v2.0 is ready for deployment!"
        echo
        log_info "Next steps:"
        echo "  1. Run: ./deploy.sh"
        echo "  2. Monitor: docker-compose logs -f"
        echo "  3. Test: curl http://localhost:3000/health"
        return 0
    else
        log_error "❌ $failed_tests test(s) failed out of $total_tests"
        log_error "Please fix the issues above before deploying"
        return 1
    fi
}

# Check for specific test
if [ $# -eq 1 ]; then
    case $1 in
        "env"|"environment")
            test_environment
            ;;
        "docker")
            test_docker
            ;;
        "sync")
            test_sync
            ;;
        "compose")
            test_docker_compose
            ;;
        "security")
            test_security
            ;;
        *)
            echo "Available tests: env, docker, sync, compose, security"
            echo "Run without arguments for full test suite"
            ;;
    esac
else
    run_all_tests
fi