param location string
param vnetName string
param resourceTags object
param vnetOctates string = '10.25'
param vnetAddressSpace string = '${vnetOctates}.0.0/16'
param bastionName string

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  tags: resourceTags
  properties: {
    enableDdosProtection: false
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '${vnetOctates}.0.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '${vnetOctates}.1.0/24'
        }
      }
      {
        name: 'vmSubnet'
        properties: {
          addressPrefix: '${vnetOctates}.2.0/24'
        }
      }
      {
        name: 'peSubnet'
        properties: {
          addressPrefix: '${vnetOctates}.3.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'webappBeSubnet'
        properties: {
          addressPrefix: '${vnetOctates}.4.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          delegations: [
            {
              name: 'webapp'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'funcBeSubnet'
        properties: {
          addressPrefix: '${vnetOctates}.5.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          delegations: [
            {
              name: 'webapp'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'laBeSubnet'
        properties: {
          addressPrefix: '${vnetOctates}.6.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          delegations: [
            {
              name: 'webapp'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
    ]
  }
}

// resource publicIp 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
//   name: 'pip-${bastionName}'
//   location: location
//   sku: {
//     name: 'Standard'
//   }
//   properties: {
//     publicIPAllocationMethod: 'Static'
//   }
// }

// resource bastionHost 'Microsoft.Network/bastionHosts@2021-08-01' = {
//   name: bastionName
//   location: location
//   properties: {
//     ipConfigurations: [
//       {
//         name: 'IpConf'
//         properties: {
//           subnet: {
//             id: vnet.properties.subnets[1].id
//           }
//           publicIPAddress: {
//             id: publicIp.id
//           }
//         }
//       }
//     ]
//   }
// }

output vnet object = vnet
output vnetId string = vnet.id
output subnets array = vnet.properties.subnets
output peSubnetId string = '${vnet.id}/subnets/peSubnet'
output funcBeSubnetId string = '${vnet.id}/subnets/funcBeSubnet'
