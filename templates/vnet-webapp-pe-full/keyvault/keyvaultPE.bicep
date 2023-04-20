param name string
param location string
param principalId string = 'fbcbb707-6c31-4630-ad42-81cfea358aa8'
param peSubnetId string
param sqlConnectionString string = ''
param resourceTags object
param deployFrontPE bool = false
param keyvaultPrivateDnsZoneId string

var privateEndpointName = 'pe-${name}'

resource KeyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: name
  location: location
  tags: resourceTags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    accessPolicies: [
      {
        tenantId: tenant().tenantId
        objectId: principalId
        permissions: {
          keys: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
            'getrotationpolicy'
            'setrotationpolicy'
            'rotate'
          ]
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
          certificates: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
            'managecontacts'
            'manageissuers'
            'getissuers'
            'listissuers'
            'setissuers'
            'deleteissuers'
          ]
        }
      }
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
  }
}

// resource DBSecret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
//   parent: KeyVault
//   name: 'dbconstr'
//   properties: {
//     value: sqlConnectionString
//   }
// }

resource PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = if (deployFrontPE) {
  name: privateEndpointName
  location: location
  tags: resourceTags
  properties: {
    subnet: {
      id: peSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: KeyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource sqlEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = if (deployFrontPE) {
  name: 'sqlDnsZoneGroup'
  parent: PrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: keyvaultPrivateDnsZoneId
        }
      }
    ]
  }
}

output vaultUri string = KeyVault.properties.vaultUri
output kvID string = KeyVault.id
