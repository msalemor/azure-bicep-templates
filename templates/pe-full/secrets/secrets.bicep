param keyvaultName string
param ascName string
param sqlConnectionString string
param funcAppName string

resource KeyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyvaultName
}

resource DBSecret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: KeyVault
  name: 'dbconstr'
  properties: {
    value: sqlConnectionString
  }
}

resource FuncURISecret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: KeyVault
  name: 'funcURI'
  properties: {
    value: 'https://${funcAppName}.azurewebsites.net/api/GetContacts'
  }
}

resource AppConfigStoreReference 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' existing = {
  name: ascName
}

resource SqlKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  name: 'settings:dbconstr'
  parent: AppConfigStoreReference
  properties: {
    tags: {}
    //contentType:
    // @description('Specifies the content type of the key-value resources. For feature flag, the value should be application/vnd.microsoft.appconfig.ff+json;charset=utf-8. For Key Value reference, the value should be application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8. Otherwise, it\'s optional.')
    value: sqlConnectionString
  }
}

resource KeyVaultKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  name: 'settings:vaultUri'
  parent: AppConfigStoreReference
  properties: {
    tags: {}
    //contentType:
    // @description('Specifies the content type of the key-value resources. For feature flag, the value should be application/vnd.microsoft.appconfig.ff+json;charset=utf-8. For Key Value reference, the value should be application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8. Otherwise, it\'s optional.')
    value: KeyVault.properties.vaultUri
  }
}

// resource ServiceAPIKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
//   name: 'settings:serviceAPI'
//   parent: AppConfigStore
//   properties: {
//     tags: {}
//     value: 'https://${funcappName}/api/GetContacts'
//   }
// }

resource WorkflowServiceURIKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  name: 'settings:workflow1URI'
  parent: AppConfigStoreReference
  properties: {
    tags: {}
    value: ''
  }
}
