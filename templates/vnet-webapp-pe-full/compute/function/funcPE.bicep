param location string

@description('The name of the Azure Function app.')
param functionAppName string

@description('The name of the Azure Function hosting plan.')
param functionAppPlanName string

@description('Specifies the OS used for the Azure Function hosting plan.')
@allowed([
  'Windows'
  'Linux'
])
param functionPlanOS string = 'Windows'

@description('Specifies the Azure Function hosting plan SKU.')
@allowed([
  'EP1'
  'EP2'
  'EP3'
])
param functionAppPlanSku string = 'EP1'

@description('The name of the backend Azure storage account used by the Azure Function app.')
param functionStorageAccountName string
param peSubnetId string
param funcBeSubnetId string
param workspaceId string
param resourceTags object
param storageFileDnsZoneId string
param storageBlobDnsZoneId string
param storageTableDnsZoneId string
param storageQueueDnsZoneId string
param deployFrontPE bool = false
param ascName string

var applicationInsightsName = 'appi-${functionAppName}'
var privateEndpointStorageFileName = 'pe-${storageAccount.name}-file'
var privateEndpointStorageTableName = 'pe-${storageAccount.name}-table'
var privateEndpointStorageBlobName = 'pe-${storageAccount.name}-blob'
var privateEndpointStorageQueueName = 'pe-${storageAccount.name}-queue'
var functionContentShareName = 'function-content-share'

// The term "reserved" is used by ARM to indicate if the hosting plan is a Linux or Windows-based plan.
// A value of true indicated Linux, while a value of false indicates Windows.
// See https://docs.microsoft.com/en-us/azure/templates/microsoft.web/serverfarms?tabs=json#appserviceplanproperties-object.
var isReserved = (functionPlanOS == 'Linux') ? true : false

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
  name: functionStorageAccountName
  location: location
  tags: resourceTags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
    }
  }
}

resource functionContentShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: '${storageAccount.name}/default/${functionContentShareName}'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: resourceTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspaceId
  }
}

resource plan 'Microsoft.Web/serverfarms@2021-01-01' = {
  location: location
  name: functionAppPlanName
  tags: resourceTags
  sku: {
    name: functionAppPlanSku
    tier: 'ElasticPremium'
    size: functionAppPlanSku
    family: 'EP'
  }
  kind: 'elastic'
  properties: {
    maximumElasticWorkerCount: 20
    reserved: isReserved
  }
}

resource AppConfigStore 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' existing = {
  name: ascName
}

resource FuncApp 'Microsoft.Web/sites@2021-03-01' = {
  location: location
  name: functionAppName
  kind: isReserved ? 'functionapp,linux' : 'functionapp'
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    storageFilePrivateDnsZoneGroup
    storageBlobPrivateDnsZoneGroup
    storageQueuePrivateDnsZoneGroup
    storageTablePrivateDnsZoneGroup
    functionContentShare
  ]
  properties: {
    serverFarmId: plan.id
    reserved: isReserved
    siteConfig: {
      functionsRuntimeScaleMonitoringEnabled: true
      linuxFxVersion: isReserved ? 'dotnet|3.1' : json('null')
      vnetRouteAllEnabled: true
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: '"WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
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
          value: functionContentShareName
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'AppConfigConnStr'
          value: AppConfigStore.listKeys().value[0].connectionString
        }
      ]
    }
  }
}

resource planNetworkConfig 'Microsoft.Web/sites/networkConfig@2021-03-01' = {
  parent: FuncApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: funcBeSubnetId
    swiftSupported: true
  }
}

// -- Private Endpoints --
resource FuncPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if (deployFrontPE) {
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
          privateLinkServiceId: FuncApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource WebAppPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = if (deployFrontPE) {
  parent: FuncPrivateEndpoint
  name: 'FuncPrivateDnsZoneGroup'
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

output objectID string = FuncApp.identity.principalId
