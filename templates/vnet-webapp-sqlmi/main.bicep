targetScope = 'subscription'

param location string = 'eastus'
param project string = 'havas'
// min 0, max 254
param version string = '12'
param environment string = 'poc'
param shortloc string = 'eus'
param vmUserName string = 'alex'
@secure()
@minLength(15)
param adminPassword string

var longdesc = '${project}${version}-${environment}-${shortloc}'
var shortdesc = '${project}${version}${environment}${shortloc}'

var rgName = 'rg-${longdesc}'
var managedInstanceName = 'sqlmi${shortdesc}'
var virtualNetworkName = 'vnet-${longdesc}'
var networkSecurityGroupName = 'nsg-${longdesc}'
var routeTableName = 'rt-${longdesc}'
var subnetName = 'ManagedInstance'
var azureBastionSubnet = 'AzureBastionSubnet'
var vnetPrefix = '10.${version}'

var tags = {
  Project: project
  Environment: environment
}

// resource group created in target subscription
resource rgGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: rgName
  location: location
  tags: tags
}

module vnet 'modules/vnet.bicep' = {
  name: 'vnet'
  scope: rgGroup
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    sqlmiSubnetName: subnetName
    networkSecurityGroupName: networkSecurityGroupName
    routeTableName: routeTableName
    azureBastionSubnet: azureBastionSubnet
    vnetPrefix: vnetPrefix
  }
}

module sqlmi 'modules/sqlmi.bicep' = {
  name: 'sqlmi'
  scope: rgGroup
  params: {
    location: location
    managedInstanceName: managedInstanceName
    subnetName: subnetName
    virtualNetworkName: virtualNetworkName
    administratorLoginPassword: adminPassword
  }
  dependsOn: [
    vnet
  ]
}

module webapp 'modules/webapp.bicep' = {
  name: 'webapp'
  scope: rgGroup
  params: {
    location: location
    appServicePlanName: 'asp${shortdesc}'
    appName: 'asp-${longdesc}'
    subnetId: vnet.outputs.beSubnetID
  }
}

module vm 'modules/vm.bicep' = {
  name: 'vm'
  scope: rgGroup
  params: {
    vmName: 'vm${shortdesc}'
    location: location
    adminUsername: vmUserName
    adminPassword: adminPassword
    virtualNetworkName: virtualNetworkName
  }
  dependsOn: [
    vnet
  ]
}

module bastion 'modules/bastion.bicep' = {
  name: project
  scope: rgGroup
  params: {
    location: location
    name: 'bastionhost'
    longdesc: longdesc
    virtualNetworkName: virtualNetworkName
    azureBastionSubnet: azureBastionSubnet
  }
  dependsOn: [
    vnet
  ]
}
