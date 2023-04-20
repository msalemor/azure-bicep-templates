param vaults_kvbicedemo2poceus_name string = 'kvbicedemo2poceus'

resource vaults_kvbicedemo2poceus_name_resource 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: vaults_kvbicedemo2poceus_name
  location: 'eastus'
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
    accessPolicies: [
      {
        tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
        objectId: 'fbcbb707-6c31-4630-ad42-81cfea358aa8'
        permissions: {
          keys: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
            'getrotationpolicy'
            'setrotationpolicy'
            'rotate'
          ]
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
          certificates: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
            'managecontacts'
            'manageissuers'
            'getissuers'
            'listissuers'
            'setissuers'
            'deleteissuers'
          ]
        }
      }
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    vaultUri: 'https://${vaults_kvbicedemo2poceus_name}.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}