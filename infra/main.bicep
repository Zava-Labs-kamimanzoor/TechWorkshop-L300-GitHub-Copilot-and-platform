// main.bicep - Entry point for ZavaStorefront Dev Environment
targetScope = 'subscription'

param environmentName string
param location string = 'westus3'

var resourceGroupName = 'rg-${environmentName}'
var appServiceName = 'app-${environmentName}'
var acrName = replace('acr${environmentName}', '-', '')
var appInsightsName = 'ai-${environmentName}'
var logAnalyticsName = 'log-${environmentName}'
var foundryName = 'foundry-${environmentName}'

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// Deploy Azure Container Registry
module acr 'modules/acr.bicep' = {
  scope: rg
  name: 'acrModule'
  params: {
    name: acrName
    location: location
  }
}

// Deploy Log Analytics Workspace
module logAnalytics 'modules/loganalytics.bicep' = {
  scope: rg
  name: 'logAnalyticsModule'
  params: {
    name: logAnalyticsName
    location: location
  }
}

// Deploy Application Insights
module appInsights 'modules/appinsights.bicep' = {
  scope: rg
  name: 'appInsightsModule'
  params: {
    name: appInsightsName
    location: location
    workspaceId: logAnalytics.outputs.id
  }
}

// Deploy Microsoft Foundry (deployed first to ensure model availability)
module foundry 'modules/foundry.bicep' = {
  scope: rg
  name: 'foundryModule'
  params: {
    name: foundryName
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

// Deploy Azure Workbook for AI Services Observability
module workbook 'modules/workbook.bicep' = {
  scope: rg
  name: 'workbookModule'
  params: {
    workbookName: guid(rg.id, 'ai-services-workbook')
    workbookDisplayName: 'AI Services Observability'
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
    workbookContent: loadTextContent('workbook-template.json')
    location: location
  }
}

// Deploy App Service Plan and Web App (depends on Foundry being ready)
module appService 'modules/appservice.bicep' = {
  scope: rg
  name: 'appServiceModule'
  dependsOn: [
    foundry
  ]
  params: {
    name: appServiceName
    location: location
    acrName: acr.outputs.name
    acrLoginServer: acr.outputs.loginServer
    appInsightsConnectionString: appInsights.outputs.connectionString
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    foundryEndpoint: foundry.outputs.endpoint
    foundryModelDeploymentName: foundry.outputs.modelDeploymentName
  }
}

// Assign AcrPull role to App Service managed identity
module acrRoleAssignment 'modules/acr-role-assignment.bicep' = {
  scope: rg
  name: 'acrRoleAssignmentModule'
  params: {
    acrName: acr.outputs.name
    principalId: appService.outputs.managedIdentityPrincipalId
  }
}

// Assign Cognitive Services OpenAI User role to App Service managed identity
module foundryRoleAssignment 'modules/foundry-role-assignment.bicep' = {
  scope: rg
  name: 'foundryRoleAssignmentModule'
  params: {
    foundryName: foundry.outputs.name
    principalId: appService.outputs.managedIdentityPrincipalId
  }
}

output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP string = resourceGroupName
output AZURE_CONTAINER_REGISTRY_NAME string = acr.outputs.name
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = acr.outputs.loginServer
output APP_SERVICE_NAME string = appService.outputs.name
output APP_SERVICE_URL string = appService.outputs.uri
output APPLICATION_INSIGHTS_NAME string = appInsights.outputs.name
output FOUNDRY_ENDPOINT string = foundry.outputs.endpoint
output FOUNDRY_MODEL_DEPLOYMENT_NAME string = foundry.outputs.modelDeploymentName
output WORKBOOK_ID string = workbook.outputs.workbookId
output SERVICE_WEB_IMAGE_NAME string = 'web:latest'
