
// Azure Static Web App deployment for Juice Roll Flutter application
// This Bicep template creates an Azure Static Web App to host the Flutter web build
// All AKS/Kubernetes resources have been removed. Use Azure Static Web Apps for deployment.

@description('The name of the Static Web App resource.')
param staticWebAppName string

@description('The Azure region where the resource will be deployed.')
param location string = 'eastus2'

@description('The SKU for the Static Web App (Free or Standard).')
@allowed([
  'Free'
  'Standard'
])
param sku string = 'Free'

@description('Optional: URL of the GitHub repository for the static site.')
param repositoryUrl string = ''

@description('Optional: The target branch in the repository.')
param repositoryBranch string = 'main'

@description('Optional: GitHub repository token for setting up GitHub Actions.')
@secure()
param repositoryToken string = ''

@description('Tags to apply to the resource.')
param tags object = {}

// Merge default tags with user-provided tags
var defaultTags = {
  application: 'juice-roll'
  environment: 'production'
  managedBy: 'bicep'
}
var mergedTags = union(defaultTags, tags)

// Static Web App resource
resource staticWebApp 'Microsoft.Web/staticSites@2024-04-01' = {
  name: staticWebAppName
  location: location
  tags: mergedTags
  sku: {
    name: sku
    tier: sku
  }
  properties: {
    // Repository configuration (optional - can be configured via GitHub Actions)
    repositoryUrl: !empty(repositoryUrl) ? repositoryUrl : null
    branch: !empty(repositoryUrl) ? repositoryBranch : null
    repositoryToken: !empty(repositoryToken) ? repositoryToken : null
    
    // Build configuration for Flutter web
    buildProperties: {
      appLocation: '/'
      outputLocation: 'build/web'
      skipGithubActionWorkflowGeneration: true
    }
    
    // Enable staging environments on Standard tier
    stagingEnvironmentPolicy: sku == 'Standard' ? 'Enabled' : 'Disabled'
    
    // Allow config file updates
    allowConfigFileUpdates: true
  }
}

// Outputs
@description('The default hostname of the Static Web App.')
output defaultHostname string = staticWebApp.properties.defaultHostname

@description('The resource ID of the Static Web App.')
output staticWebAppId string = staticWebApp.id

@description('The name of the Static Web App resource.')
output staticWebAppName string = staticWebApp.name

@description('The API key for deployment (use with GitHub Actions).')
output deploymentTokenSecretName string = 'AZURE_STATIC_WEB_APPS_API_TOKEN'
