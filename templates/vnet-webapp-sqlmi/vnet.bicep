@description('Enter virtual network address prefix.')
param addressPrefix string = '10.0.0.0/16'
@description('Enter subnet name.')
param sqlmiSubnetName string = 'ManagedInstance'
@description('Enter subnet address prefix.')
param sqlmiSubnet string = '10.0.0.0/24'
param location string
param networkSecurityGroupName string = 'nsgsqlmi'
param routeTableName string = 'routsqlmi'
param virtualNetworkName string = 'vnetsqlmi'
param azureBastionSubnet string = 'AzureBastionSubnet'

// Variables
var beSubnetPrefix = '10.0.1.0/28'
var vmSubnetPrefix = '10.0.2.0/24'
var bastionSubnet = '10.0.3.0/24'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow_tds_inbound'
        properties: {
          description: 'Allow access to data'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_redirect_inbound'
        properties: {
          description: 'Allow inbound redirect traffic to Managed Instance inside the virtual network'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '11000-11999'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1100
          direction: 'Inbound'
        }
      }
      {
        name: 'deny_all_inbound'
        properties: {
          description: 'Deny all other inbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
      {
        name: 'deny_all_outbound'
        properties: {
          description: 'Deny all other outbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource routeTable 'Microsoft.Network/routeTables@2021-08-01' = {
  name: routeTableName
  location: location
  properties: {
    disableBgpRoutePropagation: false
  }
}

var beSubnetName = 'beSubnet'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: sqlmiSubnetName
        properties: {
          addressPrefix: sqlmiSubnet
          routeTable: {
            id: routeTable.id
          }
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
          delegations: [
            {
              name: 'managedInstanceDelegation'
              properties: {
                serviceName: 'Microsoft.Sql/managedInstances'
              }
            }
          ]
        }
      }
      {
        name: beSubnetName
        properties: {
          addressPrefix: beSubnetPrefix
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'vmSubnet'
        properties: {
          addressPrefix: vmSubnetPrefix
        }
      }
      {
        name: azureBastionSubnet
        properties: {
          addressPrefix: bastionSubnet
        }
      }
    ]
  }
}

output sqlmiSubnetID string = virtualNetwork.properties.subnets[0].id
output beSubnetID string = virtualNetwork.properties.subnets[1].id
