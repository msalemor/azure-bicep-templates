// rg-bicepdemo-poc-eus
// az group create -g rg-bicepdemo-poc-eus -l eastus
// az group delete -g rg-bicepdemo-poc-eus -y
// az deployment group create -g rg-bicepdemo-poc-eus --template-file main.bicep

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

var suffix = '${domain}-${project}-${env}-${shortloc}'
var suffixnh = '${domain}${project}${env}${shortloc}'
var vnet_name = 'vnet-${suffix}'
var workspaceId = '/subscriptions/97e6e7ea-a213-4f0e-87e0-ea14b9781c76/resourcegroups/defaultresourcegroup-eus/providers/microsoft.operationalinsights/workspaces/defaultworkspace-97e6e7ea-a213-4f0e-87e0-ea14b9781c76-eus'

module network 'networking/vnet.bicep' = {
  name: vnet_name
  params: {
    resourceTags: resourceTags
    vnetName: vnet_name
    location: location
    vnetOctates: '10.2${version}'
  }
}

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

module kv 'keyvault/keyvaultPE.bicep' = {
  name: 'kv-${suffix}'
  params: {
    location: location
    name: 'kv-${suffix}'
    vnetId: network.outputs.vnetId
    peSubnetId: network.outputs.peSubnetId 
  }
}

module appconfig 'appconfig/appconfigPE.bicep' = {
  name: 'appc-${suffix}'
  params: {
    name: 'asc-${suffix}-${epoch}'
    location: location
    vnetId: network.outputs.vnetId
    peSubnetId: network.outputs.peSubnetId
    resourceTags: resourceTags
  }
}

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

module func 'compute/function/funcPE.bicep' = {
  name: 'func${suffixnh}'
  params: {
    functionAppPlanName: 'asp-func-${suffix}'
    functionAppName: 'func${suffixnh}'
    functionStorageAccountName: 'strfnc${suffixnh}'
    location: location
    peSubnetId: network.outputs.peSubnetId
    funcBeSubnetId: network.outputs.funcBeSubnetId
    workspaceId: workspaceId
    resourceTags: resourceTags
    storageFileDnsZoneId: privateDNS.outputs.storageFileDnsZoneId
    storageBlobDnsZoneId: privateDNS.outputs.storageBlobDnsZoneId
    storageQueueDnsZoneId: privateDNS.outputs.storageQueueDnsZoneId
    storageTableDnsZoneId: privateDNS.outputs.storageTableDnsZoneId
  }
  dependsOn: [
    privateDNS
  ]
}

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
  }
}

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
  }
  dependsOn: [
    privateDNS
  ]
}
