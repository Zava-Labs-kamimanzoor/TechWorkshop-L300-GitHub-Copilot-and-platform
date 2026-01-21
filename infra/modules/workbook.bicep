@description('The location for the workbook')
param location string = resourceGroup().location

@description('The name of the workbook')
param workbookName string

@description('The display name of the workbook')
param workbookDisplayName string = 'AI Services Observability'

@description('The resource ID of the Log Analytics workspace')
param logAnalyticsWorkspaceId string

@description('The serialized workbook content as JSON string')
param workbookContent string

@description('Tags to apply to the workbook')
param tags object = {}

resource workbook 'Microsoft.Insights/workbooks@2023-06-01' = {
  name: workbookName
  location: location
  tags: tags
  kind: 'shared'
  properties: {
    displayName: workbookDisplayName
    serializedData: workbookContent
    version: '1.0'
    sourceId: logAnalyticsWorkspaceId
    category: 'Azure Monitor'
  }
}

output workbookId string = workbook.id
output workbookName string = workbook.name
