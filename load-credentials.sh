#!/bin/bash

# Load credentials from credentials directory
# Usage: source ./load-credentials.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREDENTIALS_DIR="$SCRIPT_DIR/credentials"

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
    
    if [ ! -f "$credentials_file" ]; then
        log_error "Credentials file not found: $credentials_file"
        log_info "Create it with:"
        log_info "mkdir -p $CREDENTIALS_DIR"
        log_info "touch $credentials_file"
        log_info "nano $credentials_file"
        return 1
    fi
    
    # Check if file is readable
    if [ ! -r "$credentials_file" ]; then
        log_error "Cannot read credentials file: $credentials_file"
        return 1
    fi
    
    # Load the environment variables
    set -a  # automatically export all variables
    source "$credentials_file"
    set +a  # stop automatically exporting
    
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
        log_info "Edit $credentials_file and add these variables"
        return 1
    fi
    
    # Validate JSON format for Google credentials
    if ! echo "$GOOGLE_CREDENTIALS_JSON" | jq . >/dev/null 2>&1; then
        log_error "GOOGLE_CREDENTIALS_JSON is not valid JSON"
        return 1
    fi
    
    log_success "Credentials loaded successfully"
    log_info "GITHUB_TOKEN: ${GITHUB_TOKEN:0:10}... (${#GITHUB_TOKEN} chars)"
    log_info "GOOGLE_CREDENTIALS_JSON: Valid JSON (${#GOOGLE_CREDENTIALS_JSON} chars)"
    
    return 0
}

# Function to create example credentials file
create_example_credentials() {
    local example_file="$CREDENTIALS_DIR/credentials.env.example"
    
    mkdir -p "$CREDENTIALS_DIR"
    
    cat > "$example_file" << 'EOF'
# FlowAI Credentials Configuration
# Copy this file to credentials.env and fill in your actual values

# GitHub Personal Access Token
# Get from: https://github.com/settings/tokens
# Required scopes: repo, workflow
GITHUB_TOKEN=ghp_your_token_here

# Google Service Account Credentials (JSON format)
# Get from: Google Cloud Console > IAM & Admin > Service Accounts
# Enable APIs: Google Slides API, Google Drive API
GOOGLE_CREDENTIALS_JSON={"type":"service_account","project_id":"your-project","private_key_id":"...","private_key":"-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n","client_email":"service@project.iam.gserviceaccount.com","client_id":"...","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_x509_cert_url":"...","universe_domain":"googleapis.com"}
EOF
    
    log_success "Example credentials file created: $example_file"
    log_info "Copy it to credentials.env and edit with your values:"
    log_info "cp $example_file $CREDENTIALS_DIR/credentials.env"
    log_info "nano $CREDENTIALS_DIR/credentials.env"
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    echo "🔐 FlowAI Credentials Loader"
    echo "============================="
    
    if [ "$1" = "create-example" ]; then
        create_example_credentials
    else
        load_credentials
    fi
else
    # Script is being sourced
    load_credentials
fi
