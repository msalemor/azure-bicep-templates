param subscriptionId string
param name string
param location string
param hostingPlanName string
param serverFarmResourceGroup string
param alwaysOn bool
param use32BitWorkerProcess bool
param ftpsState string
param storageAccountName string
param netFrameworkVersion string
param sku string
param skuCode string
param workerSize string
param workerSizeId string
param numberOfWorkers string

resource name_resource 'Microsoft.Web/sites@2018-11-01' = {
  name: name
  kind: 'functionapp,workflowapp'
  location: location
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/97e6e7ea-a213-4f0e-87e0-ea14b9781c76/resourceGroups/rg-bicepdemo3-poc-eus/providers/Microsoft.Insights/components/aapi-la-bicedemo-eus'
  }
  properties: {
    name: name
    siteConfig: {
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
          value: reference('microsoft.insights/components/aapi-la-bicedemo-eus', '2015-05-01').InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: reference('microsoft.insights/components/aapi-la-bicedemo-eus', '2015-05-01').ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccountName_resource.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccountName_resource.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: '${toLower(name)}ab95'
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
      ]
      cors: {}
      use32BitWorkerProcess: use32BitWorkerProcess
      netFrameworkVersion: netFrameworkVersion
      ftpsState: ftpsState
    }
    serverFarmId: '/subscriptions/${subscriptionId}/resourcegroups/${serverFarmResourceGroup}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
    clientAffinityEnabled: false
    virtualNetworkSubnetId: null
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    aapi_la_bicedemo_eus
    hostingPlanName_resource
  ]
}

resource hostingPlanName_resource 'Microsoft.Web/serverfarms@2018-11-01' = {
  name: hostingPlanName
  location: location
  kind: ''
  tags: {}
  properties: {
    name: hostingPlanName
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
    maximumElasticWorkerCount: '20'
    zoneRedundant: false
  }
  sku: {
    Tier: sku
    Name: skuCode
  }
  dependsOn: []
}

resource aapi_la_bicedemo_eus 'microsoft.insights/components@2020-02-02-preview' = {
  name: 'aapi-la-bicedemo-eus'
  location: 'eastus'
  tags: {}
  properties: {
    ApplicationId: name
    Request_Source: 'IbizaWebAppExtensionCreate'
    Flow_Type: 'Redfield'
    Application_Type: 'web'
    WorkspaceResourceId: '/subscriptions/97e6e7ea-a213-4f0e-87e0-ea14b9781c76/resourcegroups/defaultresourcegroup-eus/providers/microsoft.operationalinsights/workspaces/defaultworkspace-97e6e7ea-a213-4f0e-87e0-ea14b9781c76-eus'
  }
  dependsOn: []
}

resource storageAccountName_resource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  tags: {}
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}