// modules/foundry.bicep - Azure OpenAI Service for GPT-4o-mini
param name string
param location string
param modelName string = 'gpt-4o-mini'
param deploymentName string = 'gpt-4o-mini'
param modelVersion string = '2024-07-18'

resource openai 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
  }
}

// Deploy GPT-4o-mini model
resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openai
  name: deploymentName
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: modelName
      version: modelVersion
    }
  }
}

output endpoint string = openai.properties.endpoint
output name string = openai.name
output id string = openai.id
output modelDeploymentName string = modelDeployment.name
