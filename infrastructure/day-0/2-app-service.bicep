targetScope = 'resourceGroup'

param prefix string
param location string
param containerImageName string
param containerImageVersion string
param containerRegistryName string

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: '${prefix}-app-service-plan'
  location: location
  sku: {
    name: 'B1'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: '${prefix}-app-service'
  kind: 'app,linux,container'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerImageName}:${containerImageVersion}'
      acrUseManagedIdentityCreds: true
    }
  }
}

output appService object = appService
output appServicePlan object = appServicePlan
