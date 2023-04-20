param vnetId string

// Private DNS Zone names
var privateStorageFileDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
var privateStorageTableDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'
var privateStorageBlobDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var privateStorageQueueDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'
var privateAzConfigZoneName = 'privatelink.azconfig.io'
var privateKeyvaultDnsZoneName = 'privatelink.vaultcore.azure.net'

// -- Private DNS Zones --
resource StorageFileDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageFileDnsZoneName
  location: 'global'
}

resource StorageBlobDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageBlobDnsZoneName
  location: 'global'
}

resource StorageQueueDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageQueueDnsZoneName
  location: 'global'
}

resource StorageTableDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageTableDnsZoneName
  location: 'global'
}

resource WebsitesDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurewebsites.net'
  location: 'global'
}

resource AppConfigDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateAzConfigZoneName
  location: 'global'
  properties: {}
}

resource KeyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateKeyvaultDnsZoneName
  location: 'global'
  properties: {}
}

// -- Private DNS Zone Links --
resource storageFileDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: StorageFileDnsZone
  name: '${StorageFileDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource storageBlobDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: StorageBlobDnsZone
  name: '${StorageBlobDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource storageTableDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: StorageTableDnsZone
  name: '${StorageTableDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource websiteDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: WebsitesDnsZone
  name: 'webapp-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource AppConfigDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: AppConfigDnsZone
  name: '${AppConfigDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource KeyvaultPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: KeyVaultPrivateDnsZone
  name: 'link-${privateKeyvaultDnsZoneName}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

output storageFileDnsZoneId string = StorageFileDnsZone.id
output storageBlobDnsZoneId string = StorageBlobDnsZone.id
output storageTableDnsZoneId string = StorageTableDnsZone.id
output storageQueueDnsZoneId string = StorageQueueDnsZone.id
output websiteDnsZoneId string = WebsitesDnsZone.id
output azConfigDnsZoneId string = AppConfigDnsZone.id
output keyvaultDnsZoneId string = KeyVaultPrivateDnsZone.id
