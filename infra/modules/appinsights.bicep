// modules/appinsights.bicep
param name string
param location string
param workspaceId string

resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspaceId
  }
}

output name string = ai.name
output instrumentationKey string = ai.properties.InstrumentationKey
output connectionString string = ai.properties.ConnectionString
output id string = ai.id
