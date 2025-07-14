# 🔐 Credentials Management v2.0

This directory contains sensitive credentials for FlowAI services. **NEVER commit these files to Git!**

## 📁 File Structure

```
credentials/
├── credentials.env          # GitHub token (NEVER commit)
├── google.json             # Google service account JSON (NEVER commit)
├── credentials.env.example # Template for environment variables
├── google.json.example     # Template for Google credentials
└── README.md              # This documentation
```

## 🚀 Quick Setup

### 1. Create your credentials files
```bash
# Create GitHub token file
nano credentials/credentials.env

# Create Google credentials file
nano credentials/google.json
```

### 2. Fill in your credentials

**credentials/credentials.env:**
```bash
# GitHub Personal Access Token
GITHUB_TOKEN=ghp_your_new_token_here
```

**credentials/google.json:**
```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "your-private-key-id",
  "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n",
  "client_email": "service@your-project.iam.gserviceaccount.com",
  "client_id": "your-client-id",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/service%40your-project.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
```

## 🔧 Required Credentials

### GitHub Token
- Go to: https://github.com/settings/tokens
- Create "Personal access token (classic)"
- Required scopes: `repo`, `workflow`
- Copy the token starting with `ghp_`

### Google Service Account
- Go to: Google Cloud Console > IAM & Admin > Service Accounts
- Create a new service account
- Generate and download JSON key
- Enable these APIs:
  - Google Slides API
  - Google Drive API
- Copy the entire JSON content to `google.json`

## 📋 Usage

### Load credentials
```bash
# Load all credentials into environment
source ./load-credentials.sh

# Create example files
./load-credentials.sh create-example

# Migrate from old format
./load-credentials.sh migrate
```

### Deploy with credentials
```bash
# Deploy using secure script (automatically loads credentials)
./secure-deploy.sh
```

## 🔄 Migration from v1.0

If you have the old format with `GOOGLE_CREDENTIALS_JSON` in `credentials.env`:

```bash
# Automatic migration
./load-credentials.sh migrate
```

This will:
- Extract the JSON from `credentials.env`
- Save it to `google.json`
- Remove `GOOGLE_CREDENTIALS_JSON` from `credentials.env`
- Keep only `GITHUB_TOKEN` in `credentials.env`

## ✅ Advantages of v2.0

- **🗂️ Cleaner separation**: GitHub and Google credentials in separate files
- **📝 Better editing**: JSON syntax highlighting in editors
- **🔍 Easier validation**: Direct `jq` validation on JSON file
- **🚀 Faster loading**: No need to parse JSON from environment variable
- **🔒 More secure**: File-level permissions control
- **🛠️ Better tooling**: Google SDK can directly use file path

## 🔍 Troubleshooting

### Issue: "Google credentials file not found"
```bash
# Check if file exists
ls -la credentials/google.json

# Create from example
cp credentials/google.json.example credentials/google.json
nano credentials/google.json
```

### Issue: "Invalid JSON format"
```bash
# Validate JSON syntax
jq . credentials/google.json

# Fix common issues:
# - Remove trailing commas
# - Escape quotes and newlines properly
# - Ensure proper encoding
```

### Issue: "Permission denied"
```bash
# Fix file permissions
chmod 600 credentials/credentials.env
chmod 600 credentials/google.json
```

### Issue: "Migration needed"
```bash
# If you still have old format, migrate
./load-credentials.sh migrate
```

## 🚨 Security Reminders

- ✅ Both files are in `.gitignore`
- ✅ Files are mounted read-only in containers
- ✅ Proper file permissions (600)
- ❌ Never share these files
- ❌ Never commit to version control
- ❌ Never log credential content
- ❌ Never send in emails or chat

## 🔄 File Permissions

```bash
# Correct permissions for credential files
chmod 600 credentials/credentials.env
chmod 600 credentials/google.json

# Directory should be readable
chmod 755 credentials/
```

---

🆕 **What's New in v2.0**: Separated Google credentials into dedicated `google.json` file for better security, easier management, and improved tooling support!
