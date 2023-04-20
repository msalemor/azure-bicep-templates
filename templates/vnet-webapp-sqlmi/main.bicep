targetScope = 'subscription'

param rgName string = 'rg-havas-poc-eus'
param location string = 'eastus'
param project string = 'havas'
param environment string = 'poc'
param shortloc string = 'eus'
@secure()
@minLength(15)
param adminPassword string

var longdesc = '${project}-${environment}-${shortloc}'
var shortdesc = '${project}${environment}${shortloc}'

var managedInstanceName = 'sqlmi${shortdesc}'
var virtualNetworkName = 'vnet-${longdesc}'
var networkSecurityGroupName = 'nsg-${longdesc}'
var routeTableName = 'rt-${longdesc}'
var subnetName = 'ManagedInstance'
var azureBastionSubnet = 'AzureBastionSubnet'

// resource group created in target subscription
resource rgGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: rgName
  location: location
}

module vnet 'vnet.bicep' = {
  name: 'vnet'
  scope: rgGroup
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    sqlmiSubnetName: subnetName
    networkSecurityGroupName: networkSecurityGroupName
    routeTableName: routeTableName
    azureBastionSubnet: azureBastionSubnet
  }
}

module sqlmi 'sqlmi.bicep' = {
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

module webapp 'webapp.bicep' = {
  name: 'webapp'
  scope: rgGroup
  params: {
    location: location
    appServicePlanName: 'asp${shortdesc}'
    appName: 'webapp${shortdesc}'
    subnetId: vnet.outputs.beSubnetID
  }
}

module vm 'vm.bicep' = {
  name: 'vm'
  scope: rgGroup
  params: {
    vmName: 'vm${shortdesc}'
    location: location
    adminUsername: 'admin'
    adminPassword: adminPassword
    virtualNetworkName: virtualNetworkName
  }
  dependsOn: [
    vnet
  ]
}

module bastion 'bastion.bicep' = {
  name: project
  scope: rgGroup
  params: {
    location: location
    name: 'bastionhost'
    virtualNetworkName: virtualNetworkName
    azureBastionSubnet: azureBastionSubnet
  }
  dependsOn: [
    vnet
  ]
}
