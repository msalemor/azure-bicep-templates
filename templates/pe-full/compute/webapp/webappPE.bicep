param location string = resourceGroup().location
param name string
param workspaceId string
param beSubnetId string

var appServicePlanName = 'asp-${name}-${uniqueString(resourceGroup().id)}'
var applicationInsightsName = 'appi-${name}'
var webapp_dns_name = '.azurewebsites.net'
var privateDNSZoneName = 'privatelink.azurewebsites.net'
@description('SKU family, must be minimum P1v2')
@allowed([
  'P1v2'
  'P2v2'
  'P3v2'
])
param skuFamily string = 'P1v2'
param skuSize string = 'P1v2'
var SKU_tier = 'PremiumV2'
param skuCapacity int = 1

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName  
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'     
    WorkspaceResourceId: workspaceId
  }
}

resource AspServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'P1'    
    capacity: skuCapacity
  }
  kind: 'app'
}

resource webApp 'Microsoft.Web/sites@2021-03-01' = {
  name: name
  location: location
  properties: {
    serverFarmId: AspServicePlan.id
  }
}

resource webappVnet 'Microsoft.Web/sites/networkConfig@2021-03-01' = {
  parent: webApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: beSubnetId
    swiftSupported: true
  }
}

// resource privateDnsZones 'Microsoft.Network/privateDnsZones@2018-09-01' = {
//   name: privateDNSZoneName
//   location: 'global'
//   dependsOn: [
//     virtualNetwork
//   ]
// }

// resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
//   parent: privateDnsZones
//   name: '${privateDnsZones.name}-link'
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: virtualNetwork.id
//     }
//   }
// }

// resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
//   parent: privateEndpoint
//   name: 'dnsgroupname'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: 'config1'
//         properties: {
//           privateDnsZoneId: privateDnsZones.id
//         }
//       }
//     ]
//   }
// }
