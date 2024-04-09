targetScope = 'resourceGroup'

@minLength(5)
@maxLength(47)
param prefix string

@minLength(5)
@maxLength(50)
param containerRegistryName string

param location string
param appServicePrincipalId string

param adminUserEnabled bool = false

@allowed([
  'Basic'
  'Standard'
  // 'Premium'
])
param containerRegistrySku string = 'Standard'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: containerRegistrySku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, 'cr-pull-role-assignment')
  scope: containerRegistry
  properties: {
    principalId: appServicePrincipalId
    principalType: 'ServicePrincipal'
    // roleDefinitionId references AcrPull:
    // https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  }
}

output containerRegistry object = containerRegistry
