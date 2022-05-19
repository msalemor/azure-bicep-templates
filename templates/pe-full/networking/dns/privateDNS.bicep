param vnetId string

// Private DNS Zone names
var privateStorageFileDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
var privateStorageTableDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'
var privateStorageBlobDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var privateStorageQueueDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'

// -- Private DNS Zones --
resource storageFileDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageFileDnsZoneName
  location: 'global'
}

resource storageBlobDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageBlobDnsZoneName
  location: 'global'
}

resource storageQueueDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageQueueDnsZoneName
  location: 'global'
}

resource storageTableDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageTableDnsZoneName
  location: 'global'
}

resource websitesDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurewebsites.net'
  location: 'global'
}

// -- Private DNS Zone Links --
resource storageFileDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: storageFileDnsZone
  name: '${storageFileDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource storageBlobDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: storageBlobDnsZone
  name: '${storageBlobDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource storageTableDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: storageTableDnsZone
  name: '${storageTableDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource websiteDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: websitesDnsZone
  name: 'webapp-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

output storageFileDnsZoneId string = storageFileDnsZone.id
output storageBlobDnsZoneId string = storageBlobDnsZone.id
output storageTableDnsZoneId string = storageTableDnsZone.id
output storageQueueDnsZoneId string = storageQueueDnsZone.id
output websiteDnsZoneId string = websitesDnsZone.id
