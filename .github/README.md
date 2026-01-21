# GitHub Actions Setup

## Required Secrets

### AZURE_CREDENTIALS
Create a service principal and add the JSON output as a repository secret:

```bash
az ad sp create-for-rbac \
  --name "github-actions-zavastorefront" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/rg-github-lab \
  --json-auth
```

Copy the entire JSON output and add it as a secret named `AZURE_CREDENTIALS` in your GitHub repository settings.

## Required Variables

Add these as repository variables (Settings → Secrets and variables → Actions → Variables):

| Variable Name | Value |
|--------------|-------|
| `ACR_NAME` | `acrgithublab` |
| `RESOURCE_GROUP` | `rg-github-lab` |
| `APP_SERVICE_NAME` | `app-github-lab` |

## How to Configure

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add `AZURE_CREDENTIALS`
4. Click **Variables** tab and add the three variables listed above
5. Push to the `main` branch or manually trigger the workflow

The workflow will automatically build the Docker image, push it to ACR, and deploy it to App Service.
