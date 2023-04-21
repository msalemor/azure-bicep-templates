@description('Enter managed instance name.')
param managedInstanceName string

@description('Enter user name.')
param administratorLogin string = 'SqlAdmin'

@description('Enter password.')
@secure()
param administratorLoginPassword string

@description('Enter location. If you leave this field blank resource group location would be used.')
param location string

@description('Enter sku name.')
@allowed([
  'GP_Gen5'
  'BC_Gen5'
])
param skuName string = 'GP_Gen5'

@description('Enter number of vCores.')
@allowed([
  4
  8
  16
  24
  32
  40
  64
  80
])
param vCores int = 4

@description('Enter storage size.')
@minValue(32)
@maxValue(8192)
param storageSizeInGB int = 256

@description('Enter license type.')
@allowed([
  'BasePrice'
  'LicenseIncluded'
])
param licenseType string = 'LicenseIncluded'
param virtualNetworkName string
param subnetName string

resource managedInstance 'Microsoft.Sql/managedInstances@2021-11-01' = {
  name: managedInstanceName
  clusterName: 'vc-${managedInstanceName}-${uniqueString(resourceGroup().id)})}'
  location: location
  sku: {
    name: skuName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
    storageSizeInGB: storageSizeInGB
    vCores: vCores
    licenseType: licenseType
  }
}

resource sqlDatabase 'Microsoft.Sql/managedInstances/databases@2021-11-01' = {
  parent: managedInstance
  name: 'havasdb'
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    createMode: 'Default'
  }
}
