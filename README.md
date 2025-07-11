# FlowAI N8N Elestio Deployment

This repository contains the deployment configuration for the FlowAI middleware and md2slides services.

## Structure

```
flowai-n8n-elestio/
├── deploy.sh                      # Main deployment script
├── sync.sh                        # Service sync script
├── docker-compose.override.yml    # Docker services configuration
├── credentials/                   # Google credentials (not in Git)
├── services/                      # Service source code (synced from main repo)
└── shared/                       # Shared volume data
```

## Environment Variables Required

You need to set this environment variable in your Elestio dashboard:

- `GITHUB_TOKEN`: Your GitHub personal access token (starts with `github_pat_`)

### How to set environment variables in Elestio:

1. Go to your Elestio dashboard
2. Select your service
3. Go to "Environment" tab
4. Add the variable:
   - Name: `GITHUB_TOKEN`
   - Value: `[Your GitHub token here]`
5. Save and restart the service

## Quick Deployment

1. **Clone this repository on your server:**
   ```bash
   git clone https://github.com/pmboutet/flowai-n8n-elestio.git
   cd flowai-n8n-elestio
   ```

2. **Add Google credentials:**
   ```bash
   # Copy your service account JSON file
   mkdir -p credentials
   nano credentials/google-credentials.json
   # Paste your Google service account JSON content
   ```

3. **Deploy:**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

## How it Works

The deployment script automatically:
1. Pulls latest deployment configuration from Git
2. Syncs latest service code from the main middleware repository (using GITHUB_TOKEN)
3. Stops existing services
4. Rebuilds and starts services
5. Verifies deployment

## Making Changes

- **Infrastructure changes:** Modify files in this repository and commit
- **Code changes:** Make changes in the main middleware repository
- **Deploy updates:** Simply run `./deploy.sh` on the server

The sync script ensures you always get the latest code without manual copying.

## Services

- **python-middleware:** Main API service (port 8000)
- **md2slides:** Google Slides generation service

Both services share the `./shared` volume for file exchange.

## Troubleshooting

If you get "GITHUB_TOKEN environment variable not set" error:
1. Check that the environment variable is properly set in Elestio
2. Restart your service after adding the environment variable
3. The token should have repo access permissions

## Security Notes

- GitHub token is stored securely as environment variable
- Google credentials are not versioned in Git
- All sensitive data is properly excluded from repository