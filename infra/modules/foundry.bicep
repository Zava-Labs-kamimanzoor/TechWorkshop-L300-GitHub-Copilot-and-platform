// modules/foundry.bicep - Azure OpenAI Service for GPT-4 and Phi
param name string
param location string

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

output endpoint string = openai.properties.endpoint
output name string = openai.name
output id string = openai.id
