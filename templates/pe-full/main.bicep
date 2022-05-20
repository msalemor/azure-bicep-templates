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

// az group create -g rg-bicepdemo3-poc-eus -l eastus
// az group delete -y -g rg-bicepdemo3-poc-eus
// az deployment group create -g rg-bicepdemo3-poc-eus --template-file main.bicep

param version string = '3'
param location string = resourceGroup().location
param domain string = 'ecloud'
param project string = 'sol${version}'
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

var suffix = '${domain}-${project}-${env}-${shortloc}'
var suffixnh = '${domain}${project}${env}${shortloc}'
var vnet_name = 'vnet-${suffix}'
var workspaceId = '/subscriptions/97e6e7ea-a213-4f0e-87e0-ea14b9781c76/resourcegroups/defaultresourcegroup-eus/providers/microsoft.operationalinsights/workspaces/defaultworkspace-97e6e7ea-a213-4f0e-87e0-ea14b9781c76-eus'

// Create the VNET
module network 'networking/vnet.bicep' = {
  name: vnet_name
  params: {
    resourceTags: resourceTags
    vnetName: vnet_name
    location: location
    vnetOctates: '10.2${version}'
  }
}

// Create and Link the Private DNS Zones to the VNET
module privateDNS 'networking/dns/privateDNS.bicep' = {
  name: 'privateDNS'
  params: {
    vnetId: network.outputs.vnetId
  }
}

// var AzureBastionSubnetIndex = 1
// module bastion 'networking/bastion.bicep' = {
//   name: 'bast-${suffix}'
//   params: {
//     location: location
//     bastionName: 'bast-${suffix}'    
//     bastionSubnetId: network.outputs.subnets[AzureBastionSubnetIndex].id
//     resourceTags: resourceTags
//   }
// }

// var vmSubnetIndex = 2
// module vm 'compute/vm/devvm.bicep' = {
//   name: 'vmdev'
//   params: {
//     location: location
//     user_name: 'alex'
//     user_pwd: 'Fuerte#123456'
//     vm_name: 'vmdev'
//     subnetId: network.outputs.subnets[vmSubnetIndex].id // vmSubnet
//   }
// }

// Create a SQL instance with a Private Endpoint
module sql 'data/sql/sqlPE.bicep' = {
  name: 'sql-${suffix}'
  params: {
    sqlAdministratorLogin: 'dbadmin'
    sqlname: 'sql${suffix}'
    dbname: 'db${suffixnh}'
    location: location
    vnetId: network.outputs.vnetId
    peSubnetId: network.outputs.peSubnetId
  }
}

// Create a KV with Private Endpoint and add a few secrets
module kv 'keyvault/keyvaultPE.bicep' = {
  name: 'kv${suffixnh}${epoch}'
  params: {
    location: location
    name: 'kv${suffixnh}${epoch}'
    resourceTags: resourceTags
    vnetId: network.outputs.vnetId
    peSubnetId: network.outputs.peSubnetId
    sqlConnectionString: sql.outputs.ConnectionString    
  }
}

// Create an App Configuration and add a few configuration settings
module appconfig 'appconfig/appconfigPE.bicep' = {
  name: 'asc${suffix}${epoch}'
  params: {
    name: 'asc${suffix}${epoch}'
    location: location
    vnetId: network.outputs.vnetId
    peSubnetId: network.outputs.peSubnetId
    resourceTags: resourceTags    
    sqlConnectionString: sql.outputs.ConnectionString
    vaultUri: kv.outputs.vaultUri
  }
}

// Add a FunctionApp with PE Storage and optional PE frontend
module func 'compute/function/funcPE.bicep' = {
  name: 'func${suffixnh}'
  params: {
    functionAppPlanName: 'asp-func-${suffix}'
    functionAppName: 'func${suffixnh}'
    functionStorageAccountName: 'storfn${suffixnh}'
    location: location
    peSubnetId: network.outputs.peSubnetId
    funcBeSubnetId: network.outputs.funcBeSubnetId
    workspaceId: workspaceId
    resourceTags: resourceTags
    storageFileDnsZoneId: privateDNS.outputs.storageFileDnsZoneId
    storageBlobDnsZoneId: privateDNS.outputs.storageBlobDnsZoneId
    storageQueueDnsZoneId: privateDNS.outputs.storageQueueDnsZoneId
    storageTableDnsZoneId: privateDNS.outputs.storageTableDnsZoneId
    deployFrontPE: deployFrontPE
  }
  dependsOn: [
    privateDNS
  ]
}

// Add a WebApp with PE Storage and optional PE frontend
var webAppBeSubnetIndex = 4
module webapp 'compute/webapp/webappPE.bicep' = {
  name: 'wapp-${suffix}'
  params: {
    location: location
    name: 'wapp-${suffix}'
    workspaceId: workspaceId
    beSubnetId: network.outputs.subnets[webAppBeSubnetIndex].id
    resourceTags: resourceTags
    peSubnetId: network.outputs.peSubnetId
    suffixnh: suffixnh
    storageFileDnsZoneId: privateDNS.outputs.storageFileDnsZoneId
    storageBlobDnsZoneId: privateDNS.outputs.storageBlobDnsZoneId
    storageQueueDnsZoneId: privateDNS.outputs.storageQueueDnsZoneId
    storageTableDnsZoneId: privateDNS.outputs.storageTableDnsZoneId
    websiteDnsZoneId: privateDNS.outputs.websiteDnsZoneId
    deployFrontPE: deployFrontPE
  }
}

// Add a standard Logic App with PE Storage and optional PE frontend
var laBeSubnetIndex = 6
module logicApp 'compute/logicapp/logicappPE.bicep' = {
  name: 'la-${suffix}'
  params: {
    location: location
    workspaceId: workspaceId
    name: 'la-${suffix}'
    suffixnh: suffixnh
    laBeSubnet: network.outputs.subnets[laBeSubnetIndex].id
    resourceTags: resourceTags
    peSubnetId: network.outputs.peSubnetId
    storageFileDnsZoneId: privateDNS.outputs.storageFileDnsZoneId
    storageBlobDnsZoneId: privateDNS.outputs.storageBlobDnsZoneId
    storageQueueDnsZoneId: privateDNS.outputs.storageQueueDnsZoneId
    storageTableDnsZoneId: privateDNS.outputs.storageTableDnsZoneId
    deployFrontPE: deployFrontPE
  }
  dependsOn: [
    privateDNS
  ]
}
