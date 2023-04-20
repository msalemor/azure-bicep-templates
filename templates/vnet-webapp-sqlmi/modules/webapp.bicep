@description('The location in which all resources should be deployed.')
param location string

@description('The name of the app to create.')
param appName string

param appServicePlanName string
param subnetId string
var appServicePlanSku = 'S1'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku
  }
  kind: 'app'
}

resource webApp 'Microsoft.Web/sites@2021-01-01' = {
  name: appName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    virtualNetworkSubnetId: subnetId
    httpsOnly: true
    siteConfig: {
      vnetRouteAllEnabled: true
      //http20Enabled: true
    }
  }
}
