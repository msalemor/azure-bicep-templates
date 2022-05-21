param name string
param location string
param principalId string = 'fbcbb707-6c31-4630-ad42-81cfea358aa8'
param vnetId string
param peSubnetId string
param sqlConnectionString string = ''
param resourceTags object
param deployFrontPE bool = false

var privateEndpointName = 'pe-${name}'
var privateDnsZoneName = 'privatelink.vaultcore.azure.net'

// resource WebAppAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-11-01-preview' = {
//   parent: KeyVault
//   name: 'add' 
//   properties: {
//     accessPolicies:[
//       {
//         tenantId: tenant().tenantId
//         objectId: ''
//         permissions: {
//           keys: [
//             'get'
//             'list'

//           ]
//           secrets: [
//             'get'
//             'list'
//           ]
//           certificates: [
//             'get'
//             'list'
//           ]
//         }
//       }
//     ]
//   }
// }

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

resource PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
}

resource sqlPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: PrivateDnsZone
  name: 'link-${privateDnsZoneName}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

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
          privateDnsZoneId: PrivateDnsZone.id
        }
      }
    ]
  }
}

output vaultUri string = KeyVault.properties.vaultUri
output kvID string = KeyVault.id
