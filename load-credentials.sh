#!/bin/bash

# Load credentials from credentials directory
# Usage: source ./load-credentials.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREDENTIALS_DIR="$(dirname "$SCRIPT_DIR")/credentials"

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

# Function to safely load credentials
load_credentials() {
    local credentials_file="$CREDENTIALS_DIR/credentials.env"
    local google_json_file="$CREDENTIALS_DIR/google.json"
    
    # Check credentials.env file
    if [ ! -f "$credentials_file" ]; then
        log_error "Credentials file not found: $credentials_file"
        log_info "Create it with:"
        log_info "mkdir -p $CREDENTIALS_DIR"
        log_info "touch $credentials_file"
        log_info "nano $credentials_file"
        return 1
    fi
    
    # Check google.json file
    if [ ! -f "$google_json_file" ]; then
        log_error "Google credentials file not found: $google_json_file"
        log_info "Create it with your Google service account JSON:"
        log_info "nano $google_json_file"
        return 1
    fi
    
    # Check if files are readable
    if [ ! -r "$credentials_file" ]; then
        log_error "Cannot read credentials file: $credentials_file"
        return 1
    fi
    
    if [ ! -r "$google_json_file" ]; then
        log_error "Cannot read Google credentials file: $google_json_file"
        return 1
    fi
    
    # Load the environment variables from credentials.env
    set -a  # automatically export all variables
    source "$credentials_file"
    set +a  # stop automatically exporting
    
    # Load Google credentials from JSON file
    if [ -f "$google_json_file" ]; then
        export GOOGLE_CREDENTIALS_JSON=$(cat "$google_json_file")
        export GOOGLE_APPLICATION_CREDENTIALS="$google_json_file"
    fi
    
    # Validate that critical variables are set
    local missing_vars=()
    
    if [ -z "$GITHUB_TOKEN" ]; then
        missing_vars+=("GITHUB_TOKEN")
    fi
    
    if [ -z "$GOOGLE_CREDENTIALS_JSON" ]; then
        missing_vars+=("GOOGLE_CREDENTIALS_JSON")
    fi
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        log_error "Missing required variables: ${missing_vars[*]}"
        log_info "Check your credentials files:"
        log_info "- $credentials_file (for GITHUB_TOKEN)"
        log_info "- $google_json_file (for Google credentials)"
        return 1
    fi
    
    # Validate JSON format for Google credentials
    if ! echo "$GOOGLE_CREDENTIALS_JSON" | jq . >/dev/null 2>&1; then
        log_error "Google credentials JSON is not valid"
        log_info "Check file: $google_json_file"
        return 1
    fi
    
    log_success "Credentials loaded successfully"
    log_info "GITHUB_TOKEN: ${GITHUB_TOKEN:0:10}... (${#GITHUB_TOKEN} chars)"
    log_info "GOOGLE_CREDENTIALS_JSON: Valid JSON (${#GOOGLE_CREDENTIALS_JSON} chars)"
    log_info "GOOGLE_APPLICATION_CREDENTIALS: $GOOGLE_APPLICATION_CREDENTIALS"
    
    return 0
}

# Function to create example credentials files
create_example_credentials() {
    local credentials_file="$CREDENTIALS_DIR/credentials.env.example"
    local google_json_file="$CREDENTIALS_DIR/google.json.example"
    
    mkdir -p "$CREDENTIALS_DIR"
    
    # Create credentials.env example
    cat > "$credentials_file" << 'EOF'
# FlowAI Credentials Configuration
# Copy this file to credentials.env and fill in your actual values

# GitHub Personal Access Token
# Get from: https://github.com/settings/tokens
# Required scopes: repo, workflow
GITHUB_TOKEN=ghp_your_token_here
EOF
    
    # Create google.json example
    cat > "$google_json_file" << 'EOF'
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "your-private-key-id",
  "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n",
  "client_email": "service-account@your-project.iam.gserviceaccount.com",
  "client_id": "your-client-id",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/service-account%40your-project.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
EOF
    
    log_success "Example credentials files created:"
    log_info "- $credentials_file"
    log_info "- $google_json_file"
    log_info ""
    log_info "Copy and edit them with your values:"
    log_info "cp $credentials_file $CREDENTIALS_DIR/credentials.env"
    log_info "cp $google_json_file $CREDENTIALS_DIR/google.json"
    log_info "nano $CREDENTIALS_DIR/credentials.env"
    log_info "nano $CREDENTIALS_DIR/google.json"
}

# Function to migrate from old format
migrate_credentials() {
    local old_credentials_file="$CREDENTIALS_DIR/credentials.env"
    local new_google_json_file="$CREDENTIALS_DIR/google.json"
    
    if [ -f "$old_credentials_file" ] && grep -q "GOOGLE_CREDENTIALS_JSON" "$old_credentials_file"; then
        log_info "Migrating Google credentials from old format..."
        
        # Extract Google JSON from credentials.env
        local google_json=$(grep "GOOGLE_CREDENTIALS_JSON=" "$old_credentials_file" | cut -d'=' -f2-)
        
        if [ -n "$google_json" ] && [ "$google_json" != "GOOGLE_CREDENTIALS_JSON=" ]; then
            # Write to google.json file
            echo "$google_json" | jq . > "$new_google_json_file" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                log_success "Google credentials migrated to $new_google_json_file"
                
                # Remove GOOGLE_CREDENTIALS_JSON from credentials.env
                grep -v "GOOGLE_CREDENTIALS_JSON=" "$old_credentials_file" > "$old_credentials_file.tmp" && \
                mv "$old_credentials_file.tmp" "$old_credentials_file"
                
                log_info "Removed GOOGLE_CREDENTIALS_JSON from credentials.env"
                log_info "Migration completed successfully!"
            else
                log_error "Failed to migrate - invalid JSON format"
                rm -f "$new_google_json_file"
                return 1
            fi
        fi
    fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    echo "🔐 FlowAI Credentials Loader v2.0"
    echo "====================================="
    
    case "${1:-}" in
        "create-example")
            create_example_credentials
            ;;
        "migrate")
            migrate_credentials
            ;;
        *)
            load_credentials
            ;;
    esac
else
    # Script is being sourced
    load_credentials
fi