# 🔐 Credentials Management

This directory contains sensitive credentials for FlowAI services. **NEVER commit these files to Git!**

## Setup Instructions

### 1. Create credentials file
```bash
# Create the credentials file
cp credentials.env.example credentials.env

# Edit with your actual values
nano credentials.env
```

### 2. Required Credentials

#### GitHub Token
- Go to: https://github.com/settings/tokens
- Create a new token with scopes: `repo`, `workflow`
- Copy the token starting with `ghp_`

#### Google Service Account
- Go to: Google Cloud Console > IAM & Admin > Service Accounts
- Create a new service account
- Generate and download JSON key
- Enable these APIs:
  - Google Slides API
  - Google Drive API
- Copy the entire JSON content

### 3. Security Notes

- ✅ Files in this directory are ignored by Git (`.gitignore`)
- ✅ Files are mounted read-only in Docker containers
- ✅ Proper file permissions are set (600)
- ❌ Never share these files
- ❌ Never commit to version control
- ❌ Never log credential content

### 4. File Structure

```
credentials/
├── credentials.env          # Your actual credentials (NEVER commit)
├── credentials.env.example  # Template file (safe to commit)
├── google-credentials.json  # Generated from env var (NEVER commit)
└── README.md               # This file
```

### 5. Usage

Load credentials before deployment:
```bash
# Load credentials into environment
source ./load-credentials.sh

# Or use the secure deployment script
./secure-deploy.sh
```

### 6. Troubleshooting

**Issue: "Credentials file not found"**
```bash
# Solution: Create the file
./load-credentials.sh create-example
cp credentials/credentials.env.example credentials/credentials.env
nano credentials/credentials.env
```

**Issue: "Invalid JSON"**
```bash
# Solution: Validate your Google credentials JSON
echo "$GOOGLE_CREDENTIALS_JSON" | jq .
```

**Issue: "Permission denied"**
```bash
# Solution: Fix file permissions
chmod 600 credentials/credentials.env
```

### 7. Backup & Recovery

- Store credentials securely in a password manager
- Keep backups of Google service account keys
- Document which Google Cloud project is used
- Rotate tokens regularly for security

---

🚨 **SECURITY REMINDER**: These credentials provide access to your GitHub repositories and Google Cloud resources. Treat them like passwords and never expose them publicly!
