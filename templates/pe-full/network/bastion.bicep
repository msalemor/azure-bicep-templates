param location string
param bastionName string
param resourceTags object
param bastionSubnetId string

resource publicIp 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: 'pip-${bastionName}'
  location: location
  tags: resourceTags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2021-08-01' = {
  name: bastionName
  location: location
  tags: resourceTags
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionSubnetId
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}
