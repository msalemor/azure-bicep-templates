param name string
param location string
param vnetId string
param peSubnetId string
param resourceTags object

var privateEndpointName = 'pe-${name}'
var privateDnsZoneName = 'privatelink.azconfig.io'


resource appConfigStore 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  tags: resourceTags
}

resource appConfigDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
}

resource appConfigDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: appConfigDnsZone
  name: '${appConfigDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource appConfigPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
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
          privateLinkServiceId: appConfigStore.id
          groupIds: [
            'configurationStores'
          ]
        }
      }
    ]
  }
}

resource appConfigPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: appConfigPrivateEndpoint
  name: 'appConfigDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: appConfigDnsZone.id
        }
      }
    ]
  }
}


