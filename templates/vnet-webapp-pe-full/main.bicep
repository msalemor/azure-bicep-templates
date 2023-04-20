// File: main.bicep
// Author: Alex Morales
// Purpose: Deploys a full Private Endpoint sample solutions
//

// Naming convetion:
//
// With hyphen: <TYPE>-<DOMAIN>-<PROJECT>-<ENV>-<SHORT LOCATION>-<?UID>
// Without hyphen: <TYPE><DOMAIN><PROJECT><ENV><SHORT LOCATION><?UID>
//
// Why UID: have been creating and removing resources too quickly and sometimes
// there are errors that the resources names already exists during recreationg.

param version string = '4'
// az group create -g rg-contosopj5-poc-eus -l eastus
// az group delete -y -g rg-contosopj5-poc-eus
// az deployment group create -g rg-contosopj5-poc-eus --template-file main.bicep -n deployment1

param location string = resourceGroup().location
param domain string = 'contoso'
//param domain string = 'ecloud'
param project string = 'pj${version}'
param shortloc string = 'eus'
param env string = 'poc'
param epoch int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))

param resourceTags object = {
  Application: '${domain}-${project}'
  CostCenter: '12345'
  Environment: env
  Owner: 'admin@contoso.com'
}
param deployFrontPE bool = false

var suffix = '${domain}-${project}${version}-${env}-${shortloc}'
var suffixnh = '${domain}${project}${version}${env}${shortloc}'
var vnet_name = 'vnet-${suffix}'
var workspaceId = '/subscriptions/97e6e7ea-a213-4f0e-87e0-ea14b9781c76/resourcegroups/defaultresourcegroup-eus/providers/microsoft.operationalinsights/workspaces/defaultworkspace-97e6e7ea-a213-4f0e-87e0-ea14b9781c76-eus'

// Create the VNET
module Networking 'networking/vnet.bicep' = {
  name: vnet_name
  params: {
    resourceTags: resourceTags
    vnetName: vnet_name
    location: location
    vnetOctates: '10.2${version}'
  }
}

// Create and Link the Private DNS Zones to the VNET
module PrivateDNS 'networking/privateDNS/privateDNS.bicep' = {
  name: 'privateDNS'
  params: {
    vnetId: Networking.outputs.vnetId
  }
}

var AzureBastionSubnetIndex = 1
module Bastion 'networking/bastion.bicep' = {
  name: 'bast-${suffix}'
  params: {
    location: location
    bastionName: 'bast-${suffix}'
    bastionSubnetId: Networking.outputs.subnets[AzureBastionSubnetIndex].id
    resourceTags: resourceTags
  }
}

var vmSubnetIndex = 2
module DevVM 'compute/vm/devvm.bicep' = {
  name: 'vmdev'
  params: {
    location: location
    user_name: 'alex'
    user_pwd: 'Fuerte#123456'
    vm_name: 'vmdev'
    subnetId: Networking.outputs.subnets[vmSubnetIndex].id // vmSubnet
  }
}

// Create a SQL instance with a Private Endpoint
module SQLServerAndDatabase 'data/sql/sqlPE.bicep' = {
  name: 'sql-${suffix}'
  params: {
    sqlAdministratorLogin: 'dbadmin'
    sqlname: 'sql${suffix}'
    dbname: 'db${suffixnh}'
    location: location
    vnetId: Networking.outputs.vnetId
    peSubnetId: Networking.outputs.peSubnetId
  }
}

// Create a KV with Private Endpoint and add a few secrets
var keyvaultName = 'kv-${suffix}'
module KeyVault 'keyvault/keyvaultPE.bicep' = {
  name: 'kv-${suffix}'
  params: {
    location: location
    name: keyvaultName
    resourceTags: resourceTags
    peSubnetId: Networking.outputs.peSubnetId
    keyvaultPrivateDnsZoneId: PrivateDNS.outputs.keyvaultDnsZoneId
    //sqlConnectionString: sql.outputs.ConnectionString
    deployFrontPE: deployFrontPE
  }
  dependsOn: [
    PrivateDNS
  ]
}

// Create an App Configuration and add a few configuration settings
module AppConfiguration 'appconfig/appconfigPE.bicep' = {
  name: 'asc${suffix}${epoch}'
  params: {
    name: 'asc${suffix}${epoch}'
    location: location
    peSubnetId: Networking.outputs.peSubnetId
    resourceTags: resourceTags
    azConfigDnsZoneId: PrivateDNS.outputs.azConfigDnsZoneId
    deployFrontPE: deployFrontPE
  }
  dependsOn: [
    PrivateDNS
  ]
}

// Add a FunctionApp with PE Storage and optional PE frontend
module FuncApp 'compute/function/funcPE.bicep' = {
  name: 'fnapp-${suffix}'
  params: {
    ascName: 'asc${suffix}${epoch}'
    functionAppPlanName: 'asp-func-${suffix}'
    functionAppName: 'fnapp-${suffix}'
    functionStorageAccountName: 'storfn${suffixnh}'
    location: location
    peSubnetId: Networking.outputs.peSubnetId
    funcBeSubnetId: Networking.outputs.funcBeSubnetId
    workspaceId: workspaceId
    resourceTags: resourceTags
    storageFileDnsZoneId: PrivateDNS.outputs.storageFileDnsZoneId
    storageBlobDnsZoneId: PrivateDNS.outputs.storageBlobDnsZoneId
    storageQueueDnsZoneId: PrivateDNS.outputs.storageQueueDnsZoneId
    storageTableDnsZoneId: PrivateDNS.outputs.storageTableDnsZoneId
    deployFrontPE: deployFrontPE
  }
  dependsOn: [
    PrivateDNS
    AppConfiguration
  ]
}

// Add a WebApp with PE Storage and optional PE frontend
var webAppBeSubnetIndex = 4
module WebApp 'compute/webapp/webappPE.bicep' = {
  name: 'wapp-${suffix}'
  params: {
    location: location
    name: 'wapp-${suffix}'
    workspaceId: workspaceId
    beSubnetId: Networking.outputs.subnets[webAppBeSubnetIndex].id
    resourceTags: resourceTags
    peSubnetId: Networking.outputs.peSubnetId
    suffixnh: suffixnh
    storageFileDnsZoneId: PrivateDNS.outputs.storageFileDnsZoneId
    storageBlobDnsZoneId: PrivateDNS.outputs.storageBlobDnsZoneId
    storageQueueDnsZoneId: PrivateDNS.outputs.storageQueueDnsZoneId
    storageTableDnsZoneId: PrivateDNS.outputs.storageTableDnsZoneId
    websiteDnsZoneId: PrivateDNS.outputs.websiteDnsZoneId
    keyvaultName: keyvaultName
    deployFrontPE: false
  }
  dependsOn: [
    PrivateDNS
  ]
}

// Add a standard Logic App with PE Storage and optional PE frontend
var laBeSubnetIndex = 6
module LAApp 'compute/logicapp/logicappPE.bicep' = {
  name: 'laapp-${suffix}'
  params: {
    location: location
    workspaceId: workspaceId
    name: 'la-${suffix}'
    suffixnh: suffixnh
    laBeSubnet: Networking.outputs.subnets[laBeSubnetIndex].id
    resourceTags: resourceTags
    peSubnetId: Networking.outputs.peSubnetId
    storageFileDnsZoneId: PrivateDNS.outputs.storageFileDnsZoneId
    storageBlobDnsZoneId: PrivateDNS.outputs.storageBlobDnsZoneId
    storageQueueDnsZoneId: PrivateDNS.outputs.storageQueueDnsZoneId
    storageTableDnsZoneId: PrivateDNS.outputs.storageTableDnsZoneId
    deployFrontPE: deployFrontPE
  }
  dependsOn: [
    PrivateDNS
  ]
}

module AddKVPolicies 'keyvault/addpolicies.bicep' = {
  name: 'addkvpolicies'
  params: {
    keyvaultName: KeyVault.name
    laappObjectID: LAApp.outputs.objectID
    funcappObjectID: FuncApp.outputs.objectID
    ascObjectID: AppConfiguration.outputs.objectID
    webappObjectID: WebApp.outputs.objectID
  }
}

module AddSecrets 'secrets/secrets.bicep' = {
  name: 'add-secrets'
  params: {
    ascName: AppConfiguration.name
    funcAppName: FuncApp.name
    keyvaultName: KeyVault.name
    sqlConnectionString: SQLServerAndDatabase.outputs.ConnectionString
  }
}

// TODO: use the vnet in another module
output vnetID string = Networking.outputs.vnetId
output kvURI string = KeyVault.outputs.vaultUri
output kvID string = KeyVault.outputs.kvID
output webappPrincipalID string = WebApp.outputs.objectID
output laappPrincipalID string = LAApp.outputs.objectID
output funcappPrincipalID string = FuncApp.outputs.objectID
