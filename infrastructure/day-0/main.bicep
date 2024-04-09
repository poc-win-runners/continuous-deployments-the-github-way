targetScope = 'subscription'

param phase string
param location string

param uid string = take(toLower(uniqueString(subscription().subscriptionId, utcNow())), 6)
param prefix string = 'gh-universe24-${uid}'

param resourceGroupName string = '${prefix}-rg'

param containerImageName string = 'app'
param containerImageVersion string = '1'
param containerRegistryName string = replace(prefix, '-', '')

module resourcegroup '1-resource-group.bicep' = {
  name: '${phase}-1-resource-group.bicep'
  params: {
    location: location
    resourceGroupName: resourceGroupName
  }
}

module site '2-app-service.bicep' = {
  name: '${phase}-2-app-service.bicep'
  scope: resourceGroup(resourceGroupName)
  params: {
    prefix: prefix
    location: location
    containerImageName: containerImageName
    containerImageVersion: containerImageVersion
    containerRegistryName: containerRegistryName
  }
  dependsOn: [
    resourcegroup
  ]
}

module githubIntegrationApp '3-application-identity-registration.bicep' = {
  name: '${phase}-3-application-identity-registration.bicep'
  scope: resourceGroup(resourceGroupName)
  params: {
    prefix: prefix
  }
  dependsOn: [
    resourcegroup
    site
  ]
}

module containerRegistry '4-container-registry.bicep' = {
  name: '${phase}-4-container-registry.bicep'
  scope: resourceGroup(resourceGroupName)
  params: {
    prefix: prefix
    location: location
    adminUserEnabled: false
    containerRegistryName: containerRegistryName
    appServicePrincipalId: site.outputs.appService.identity.principalId
  }
  dependsOn: [
    resourcegroup
    site
    githubIntegrationApp
  ]
}

output githubIntegrationApp object = githubIntegrationApp
output containerRegistry object = containerRegistry
output resourcegroup object = resourcegroup
output site object = site
