# FlowAI N8N Elestio Deployment

This repository contains the deployment configuration for the FlowAI middleware and md2slides services.

## Structure

```
flowai-n8n-elestio/
├── deploy.sh                      # Main deployment script
├── sync.sh                        # Service sync script
├── docker-compose.override.yml    # Docker services configuration
├── services/                      # Service source code (synced from main repo)
└── shared/                       # Shared volume data
```

## Environment Variables Required

You need to set these environment variables in your Elestio dashboard:

### 1. GitHub Token
- **Name:** `GITHUB_TOKEN`
- **Value:** Your GitHub personal access token (starts with `github_pat_`)

### 2. Google Credentials
- **Name:** `GOOGLE_CREDENTIALS_JSON`
- **Value:** Your complete Google service account JSON (the entire JSON content)

### How to set environment variables in Elestio:

1. Go to your Elestio dashboard
2. Select your service
3. Go to "Environment" tab
4. Add the variables:
   - `GITHUB_TOKEN`: `[Your GitHub token]`
   - `GOOGLE_CREDENTIALS_JSON`: `[Your complete Google service account JSON]`
5. Save and restart the service

## Quick Deployment

1. **Clone this repository on your server:**
   ```bash
   git clone https://github.com/pmboutet/flowai-n8n-elestio.git
   cd flowai-n8n-elestio
   ```

2. **Deploy (no manual file setup needed!):**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

## How it Works

The deployment script automatically:
1. Checks that required environment variables are set
2. Pulls latest deployment configuration from Git
3. Syncs latest service code from the main middleware repository
4. Stops existing services
5. Rebuilds and starts services with environment variables
6. Verifies deployment

## Making Changes

- **Infrastructure changes:** Modify files in this repository and commit
- **Code changes:** Make changes in the main middleware repository
- **Deploy updates:** Simply run `./deploy.sh` on the server

## Services

- **python-middleware:** Main API service (port 8000)
- **md2slides:** Google Slides generation service

Both services share the `./shared` volume for file exchange.

## Benefits of Environment Variables

✅ **No files to manage on server**  
✅ **Secure credential storage**  
✅ **Easy credential rotation**  
✅ **Fully Git-managed deployment**  
✅ **Zero manual configuration**  

## Troubleshooting

Common errors and solutions:

1. **"GITHUB_TOKEN environment variable not set"**
   - Set the GitHub token in Elestio environment variables
   - Restart the service after adding variables

2. **"GOOGLE_CREDENTIALS_JSON environment variable not set"**
   - Set the complete Google service account JSON in Elestio
   - Make sure it's the full JSON content, not just a file path

3. **Authentication errors**
   - Verify your GitHub token has repo access
   - Verify your Google credentials are valid and have the right APIs enabled