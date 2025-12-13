
# Azure Infrastructure for Juice Roll

This directory contains the Azure Bicep templates for deploying Juice Roll as an Azure Static Web App.
All previous AKS/Kubernetes deployment files and instructions have been removed. Use Azure Static Web Apps for deployment.

## Prerequisites

1. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and configured
2. An Azure subscription
3. A resource group created in your subscription

## Quick Start

### 1. Login to Azure

```bash
az login
```

### 2. Set your subscription (if you have multiple)

```bash
az account set --subscription "<your-subscription-id>"
```

### 3. Create a resource group (if needed)

```bash
az group create --name rg-juice-roll --location eastus2
```

### 4. Deploy the infrastructure

```bash
# Deploy with default parameters
az deployment group create \
  --resource-group rg-juice-roll \
  --template-file main.bicep \
  --parameters main.bicepparam

# Or deploy with inline parameter overrides
az deployment group create \
  --resource-group rg-juice-roll \
  --template-file main.bicep \
  --parameters staticWebAppName='my-juice-roll-app' sku='Free'
```

### 5. Get the deployment token for GitHub Actions

After deployment, retrieve the deployment token:

```bash
az staticwebapp secrets list \
  --name <your-static-web-app-name> \
  --resource-group rg-juice-roll \
  --query "properties.apiKey" \
  --output tsv
```

### 6. Configure GitHub Actions

1. Go to your GitHub repository settings
2. Navigate to **Secrets and variables** > **Actions**
3. Create a new repository secret named `AZURE_STATIC_WEB_APPS_API_TOKEN`
4. Paste the API token from step 5

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `staticWebAppName` | string | Required | The name of the Static Web App (must be globally unique) |
| `location` | string | `eastus2` | Azure region for deployment |
| `sku` | string | `Free` | SKU tier: `Free` or `Standard` |
| `repositoryUrl` | string | `''` | Optional GitHub repository URL |
| `repositoryBranch` | string | `main` | Target branch for deployment |
| `repositoryToken` | securestring | `''` | GitHub token (not recommended for CLI deployment) |
| `tags` | object | `{}` | Additional resource tags |

## SKU Comparison

| Feature | Free | Standard |
|---------|------|----------|
| Custom domains | 2 | 5 |
| SSL certificates | Included | Included |
| Staging environments | No | Yes |
| Max app size | 250 MB | 500 MB |
| Bandwidth | 100 GB/month | 100 GB/month |
| SLA | None | 99.95% |

## Outputs

After deployment, the following outputs are available:

- `defaultHostname`: The auto-generated hostname for your app
- `staticWebAppId`: The Azure resource ID
- `staticWebAppName`: The name of the deployed resource

## Manual Deployment (without GitHub Actions)

If you prefer to deploy manually:

1. Build the Flutter web app locally:
   ```bash
   flutter build web --release
   ```

2. Install the Azure Static Web Apps CLI:
   ```bash
   npm install -g @azure/static-web-apps-cli
   ```

3. Deploy:
   ```bash
   swa deploy ./build/web \
     --deployment-token <your-deployment-token> \
     --env production
   ```

## Cleanup

To delete all resources:

```bash
az group delete --name rg-juice-roll --yes --no-wait
```

Or delete just the Static Web App:

```bash
az staticwebapp delete --name <your-static-web-app-name> --resource-group rg-juice-roll
```
