targetScope = 'resourceGroup'

extension microsoftGraph

param prefix string

param signInAudience string = 'AzureADMyOrg'
param contributorRoleDefinitionID string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource githubIntegrationApp 'Microsoft.Graph/applications@v1.0' = {
  uniqueName: '${prefix}-github-integration-app'
  displayName: '${prefix} GitHub Integration App'
  signInAudience: signInAudience
  web: {
    implicitGrantSettings: {
      enableIdTokenIssuance: true
      enableAccessTokenIssuance: true
    }
  }
  requiredResourceAccess: [
    {
      // https://learn.microsoft.com/en-us/troubleshoot/azure/entra/entra-id/governance/verify-first-party-apps-sign-in
      resourceAppId: '00000003-0000-0000-c000-000000000000'
      resourceAccess: [
        // User.Read
        { id: 'e1fe6dd8-ba31-4d61-89e7-88639da4683d', type: 'Scope' }
        // offline_access
        { id: '7427e0e9-2fba-42fe-b0c0-848c9e6a8182', type: 'Scope' }
        // openid
        { id: '37f7f235-527c-4136-accd-4a02d197296e', type: 'Scope' }
        // profile
        { id: '14dad69e-099b-42c9-810b-d002981feec1', type: 'Scope' }
      ]
    }
  ]
}

resource githubIntegrationServicePrincipal 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: githubIntegrationApp.appId
}

resource githubIntegrationAppRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, 'github-integration-contributor-role-assignment')
  properties: {
    principalType: 'ServicePrincipal'
    principalId: githubIntegrationServicePrincipal.id
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionID)
  }
}

output applicationRegistration object = githubIntegrationApp
output servicePrincipal object = githubIntegrationServicePrincipal
output roleAssignment object = githubIntegrationAppRoleAssignment
