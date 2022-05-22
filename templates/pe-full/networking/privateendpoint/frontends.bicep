param location string
param resourceTags object
param peSubnetID string
param deployFrontPE bool = false
param webappName string
param webappDnsZoneID string

resource WebAppReference 'Microsoft.Web/sites@2021-03-01' existing = {
  name: webappName
}

// -- Private Endpoints --
resource WebAppPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if (deployFrontPE) {
  name: 'pe-webapp'
  location: location
  tags: resourceTags
  properties: {
    subnet: {
      id: peSubnetID
    }
    privateLinkServiceConnections: [
      {
        name: 'WebAppPrivateLinkConnection'
        properties: {
          privateLinkServiceId: WebAppReference.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource WebAppPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = if (deployFrontPE) {
  parent: WebAppPrivateEndpoint
  name: 'WebAppPrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: webappDnsZoneID
        }
      }
    ]
  }
}
