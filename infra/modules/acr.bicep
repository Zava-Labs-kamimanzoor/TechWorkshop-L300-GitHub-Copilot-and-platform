// modules/acr.bicep
param name string
param location string

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

output name string = acr.name
output loginServer string = acr.properties.loginServer
output id string = acr.id
