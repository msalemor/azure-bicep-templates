param name string
param location string
param vnetId string
param peSubnetId string
param resourceTags object
param sqlConnectionString string
param vaultUri string = ''
param deployFrontPE bool = false

var privateEndpointName = 'pe-${name}'
var privateDnsZoneName = 'privatelink.azconfig.io'

resource AppConfigStore 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  tags: resourceTags
}

resource symbolicname1 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  name: 'dbconstr'
  parent: AppConfigStore
  properties: {
    tags: {}
    //contentType:
    // @description('Specifies the content type of the key-value resources. For feature flag, the value should be application/vnd.microsoft.appconfig.ff+json;charset=utf-8. For Key Value reference, the value should be application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8. Otherwise, it\'s optional.')
    value: sqlConnectionString
  }
}

resource symbolicname2 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  name: 'vaultUri'
  parent: AppConfigStore
  properties: {
    tags: {}
    //contentType:
    // @description('Specifies the content type of the key-value resources. For feature flag, the value should be application/vnd.microsoft.appconfig.ff+json;charset=utf-8. For Key Value reference, the value should be application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8. Otherwise, it\'s optional.')
    value: vaultUri
  }
}

resource AppConfigDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
}

resource AppConfigDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: AppConfigDnsZone
  name: '${AppConfigDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

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

resource appConfigPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = if (deployFrontPE) {
  parent: AppConfigPrivateEndpoint
  name: 'appConfigDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: AppConfigDnsZone.id
        }
      }
    ]
  }
}
