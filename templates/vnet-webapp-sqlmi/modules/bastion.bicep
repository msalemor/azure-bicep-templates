param name string
param location string
param virtualNetworkName string = 'vnet'
param azureBastionSubnet string = 'AzureBastionSubnet'

resource publicIpAddressForBastion 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'pip-bastion-${name}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name: 'bastion-${name}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, azureBastionSubnet)
          }
          publicIPAddress: {
            id: publicIpAddressForBastion.id
          }
        }
      }
    ]
  }
}
