param location string = resourceGroup().location
param name string
param workspaceId string
param beSubnetId string

var appServicePlanName = 'asp-${name}'
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
param skuCapacity int = 1
param resourceTags object
param peSubnetId string
param suffixnh string
param storageAccountName string = 'storwapp${suffixnh}'
param storageFileDnsZoneId string 
param storageBlobDnsZoneId string 
param storageTableDnsZoneId string
param storageQueueDnsZoneId string
param websiteDnsZoneId string
param deployFrontPE bool = false

var SKU_tier = 'PremiumV2'
var privateEndpointStorageFileName = 'pe-${storageAccountName}-file'
var privateEndpointStorageTableName = 'pe-${storageAccountName}-table'
var privateEndpointStorageBlobName = 'pe-${storageAccountName}-blob'
var privateEndpointStorageQueueName = 'pe-${storageAccountName}-queue'
var webAppContentShareName = 'webapp-content-share'

// -- Private DNS Zone Groups --
resource storageFilePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: storageFilePrivateEndpoint
  name: 'filePrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: storageFileDnsZoneId
        }
      }
    ]
  }
}

resource storageBlobPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: storageBlobPrivateEndpoint
  name: 'blobPrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: storageBlobDnsZoneId
        }
      }
    ]
  }
}

resource storageTablePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: storageTablePrivateEndpoint
  name: 'tablePrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: storageTableDnsZoneId
        }
      }
    ]
  }
}

resource storageQueuePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: storageQueuePrivateEndpoint
  name: 'tablePrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: storageQueueDnsZoneId
        }
      }
    ]
  }
}
// -- Private Endpoints --
resource storageFilePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: privateEndpointStorageFileName
  location: location
  tags: resourceTags
  properties: {
    subnet: {
      id: peSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageFilePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }
}

resource storageTablePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: privateEndpointStorageTableName
  location: location
  tags: resourceTags
  properties: {
    subnet: {
      id: peSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageTablePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'table'
          ]
        }
      }
    ]
  }
}

resource storageQueuePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: privateEndpointStorageQueueName
  location: location
  tags: resourceTags
  properties: {
    subnet: {
      id: peSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageQueuePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'queue'
          ]
        }
      }
    ]
  }
}

resource storageBlobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: privateEndpointStorageBlobName
  location: location
  tags: resourceTags
  properties: {
    subnet: {
      id: peSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageBlobPrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  tags: resourceTags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    // networkAcls: {
    //   bypass: 'None'
    //   defaultAction: 'Deny'
    // }
  }
}

resource WebContentShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: '${storageAccount.name}/default/${webAppContentShareName}'  
}

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
    name: skuFamily
    tier: SKU_tier
    capacity: skuCapacity
  }
  kind: 'app'
}

resource WebApp 'Microsoft.Web/sites@2021-03-01' = {
  name: name
  location: location
  kind: 'app'
  identity: {
     type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: AspServicePlan.id    
    siteConfig: {
      vnetRouteAllEnabled: true
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value:  appInsights.properties.ConnectionString
        }        
        // {
        //   name: 'WEBSITE_VNET_ROUTE_ALL'
        //   value: '1'
        // }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: webAppContentShareName
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
      ]
    }  
  }
}

resource webappVnet 'Microsoft.Web/sites/networkConfig@2021-03-01' = {
  parent: WebApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: beSubnetId
    swiftSupported: true    
  }
}


// -- Private Endpoints --
resource WebAppPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' =  if (deployFrontPE) {
  name: 'pe-webapp'
  location: location
  tags: resourceTags
  properties: {
    subnet: {
      id: peSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'WebAppPrivateLinkConnection'
        properties: {
          privateLinkServiceId: WebApp.id
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
          privateDnsZoneId: websiteDnsZoneId
        }
      }
    ]
  }
}

output objectId string = WebApp.identity.principalId
