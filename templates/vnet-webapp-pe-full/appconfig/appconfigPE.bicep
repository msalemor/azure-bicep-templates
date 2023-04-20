param name string
param location string
param peSubnetId string
param resourceTags object
param deployFrontPE bool = false
param azConfigDnsZoneId string

var privateEndpointName = 'pe-${name}'

resource AppConfigStore 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: resourceTags
}

// resource SqlKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
//   name: 'settings:dbconstr'
//   parent: AppConfigStore
//   properties: {
//     tags: {}
//     //contentType:
//     // @description('Specifies the content type of the key-value resources. For feature flag, the value should be application/vnd.microsoft.appconfig.ff+json;charset=utf-8. For Key Value reference, the value should be application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8. Otherwise, it\'s optional.')
//     value: sqlConnectionString
//   }
// }

// resource KeyVaultKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
//   name: 'settings:vaultUri'
//   parent: AppConfigStore
//   properties: {
//     tags: {}
//     //contentType:
//     // @description('Specifies the content type of the key-value resources. For feature flag, the value should be application/vnd.microsoft.appconfig.ff+json;charset=utf-8. For Key Value reference, the value should be application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8. Otherwise, it\'s optional.')
//     value: vaultUri
//   }
// }

// resource ServiceAPIKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
//   name: 'settings:serviceAPI'
//   parent: AppConfigStore
//   properties: {
//     tags: {}
//     value: 'https://${funcappName}/api/GetContacts'
//   }
// }

// resource WorkflowServiceURIKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
//   name: 'settings:workflow1URI'
//   parent: AppConfigStore
//   properties: {
//     tags: {}
//     value: ''
//   }
// }

resource AppConfigPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if (deployFrontPE) {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: peSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'appConfigPrivateLinkConnection'
        properties: {
          privateLinkServiceId: AppConfigStore.id
          groupIds: [
            'configurationStores'
          ]
        }
      }
    ]
  }
}

resource AppConfigPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = if (deployFrontPE) {
  parent: AppConfigPrivateEndpoint
  name: 'appConfigDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: azConfigDnsZoneId
        }
      }
    ]
  }
}

output acStoreURI string = AppConfigStore.properties.endpoint
output objectID string = AppConfigStore.identity.principalId
//output acStoreX string = AppConfigStore.listKeys().keys[0].value

//Endpoint=https://asccontoso-pj5-poc-eus1684779006.azconfig.io;Id=Nro2-l0-s0:hHq1ynPioxgz9ialt2MG;Secret=1pl6cHZrb5OymtrX1ARLoQMzXxDtlvMvnHmm3dd1Fxg=
//output acStoreProperties object = AppConfigStore
//output x string = AppConfigStore.listKeys().value[0].connectionString
