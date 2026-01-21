// modules/appservice.bicep
param name string
param location string
param acrName string
param acrLoginServer string
param appInsightsConnectionString string
param appInsightsInstrumentationKey string
param foundryEndpoint string
param foundryModelDeploymentName string

resource plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${name}-plan'
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource app 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: 'app,linux,container'
  tags: {
    'azd-service-name': 'web'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrLoginServer}/web:latest'
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FOUNDRY_ENDPOINT'
          value: foundryEndpoint
        }
        {
          name: 'FOUNDRY_MODEL_DEPLOYMENT_NAME'
          value: foundryModelDeploymentName
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'WEBSITES_PORT'
          value: '8080'
        }
      ]
      acrUseManagedIdentityCreds: true
    }
  }
}

output name string = app.name
output uri string = 'https://${app.properties.defaultHostName}'
output managedIdentityPrincipalId string = app.identity.principalId
output id string = app.id
