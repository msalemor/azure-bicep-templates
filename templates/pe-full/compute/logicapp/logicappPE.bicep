param name string
param location string
param workspaceId string
param suffixnh string
param laBeSubnet string
param peSubnetId string
param resourceTags object
param storageFileDnsZoneId string
param storageBlobDnsZoneId string
param storageTableDnsZoneId string
param storageQueueDnsZoneId string
param deployFrontPE bool = false
//
var laContentShareName = 'la-content-share'
var hostingPlanName = 'asp-${name}'
var storageAccountName = 'storla${suffixnh}'
var privateEndpointStorageFileName = 'pe-${StorageAccount.name}-file'
var privateEndpointStorageTableName = 'pe-${StorageAccount.name}-table'
var privateEndpointStorageBlobName = 'pe-${StorageAccount.name}-blob'
var privateEndpointStorageQueueName = 'pe-${StorageAccount.name}-queue'

resource ApplicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'aapi-${name}'
  location: location
  tags: {}
  kind: ''
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspaceId
  }
  dependsOn: []
}

resource StorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
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

resource laContentShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
  name: '${StorageAccount.name}/default/${laContentShareName}'
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
          privateLinkServiceId: StorageAccount.id
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
          privateLinkServiceId: StorageAccount.id
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
          privateLinkServiceId: StorageAccount.id
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
          privateLinkServiceId: StorageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

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

// Service plan
resource AspServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  tags: {}
  sku: {
    name: 'WS1'
    tier: 'WorkflowStandard'
    family: 'WS'
    capacity: 1
  }
  dependsOn: []
}

resource LogicApp 'Microsoft.Web/sites@2021-03-01' = {
  name: name
  kind: 'functionapp,workflowapp'
  location: location
  properties: {
    siteConfig: {
      vnetRouteAllEnabled: true
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: ApplicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: ApplicationInsights.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${StorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${StorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: laContentShareName
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }
        // {
        //   name: 'WEBSITE_VNET_ROUTE_ALL'
        //   value: '1'
        // }
      ]
      cors: {}
      use32BitWorkerProcess: true
      //netFrameworkVersion: netFrameworkVersion
      // ftpsState: ftpsState
    }
    serverFarmId: AspServicePlan.id
    clientAffinityEnabled: false
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource LAAppNetworkConfig 'Microsoft.Web/sites/networkConfig@2021-03-01' = {
  parent: LogicApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: laBeSubnet
    swiftSupported: true
  }
}

// -- Private Endpoints --
resource LAPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if (deployFrontPE) {
  name: 'pe-la'
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
          privateLinkServiceId: LogicApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource WebAppPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = if (deployFrontPE) {
  parent: LAPrivateEndpoint
  name: 'LaPrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: ''
        }
      }
    ]
  }
}

output objectID string = LogicApp.identity.principalId
