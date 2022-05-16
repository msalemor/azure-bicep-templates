// rg-bicepdemo-poc-eus
param version string = '7'
// az group delete -g rg-bicepdemo-poc-eus -y
// az group create -g rg-bicepdemo-poc-eus -l eastus
// az deployment group create -g rg-bicepdemo-poc-eus --template-file main.bicep
param location string = resourceGroup().location
param domain string = 'ecloud'
param project string = 'sol${version}'
param shortloc string = 'eus'
param env string = 'poc'

param resourceTags object = {
  Application: '${domain}-${project}'
  CostCenter: '12345'
  Environment: env
  Owner: 'admin@contoso.com'
}

var suffix = '${domain}-${project}-${env}-${shortloc}'
var suffixnh = '${domain}${project}${env}${shortloc}'
//var funcstorage_name = 'stor${suffixnh}001'
//var lastorage_name = 'stor${suffixnh}002'
var vnet_name = 'vnet-${suffix}'
var workspaceId = '/subscriptions/97e6e7ea-a213-4f0e-87e0-ea14b9781c76/resourcegroups/defaultresourcegroup-eus/providers/microsoft.operationalinsights/workspaces/defaultworkspace-97e6e7ea-a213-4f0e-87e0-ea14b9781c76-eus'

module network 'network/vnet.bicep' = {
  name: vnet_name
  params: {
    resourceTags: resourceTags
    vnetName: vnet_name
    location: location
    bastionName: 'bast-${suffix}'
    vnetOctates: '10.2${version}'
  }
}

// module bastion 'network/bastion.bicep' = {
//   name: 'bast-${suffix}'
//   params: {
//     bastionName: 'bast-${suffix}'
//     location: location
//     resourceTags: resourceTags
//     bastionSubnetId: network.outputs.subnets[1].id
//   }
// }

// module func_storage 'storage/storage.bicep' = {
//   name: funcstorage_name
//   params: {
//     resourceTags: resourceTags
//     location: location
//     name: funcstorage_name
//     vnetId: network.outputs.vnetId
//     privateLinkSubnetId: network.outputs.privateLinkSubnetId
//   }
// }

// module la_storage 'storage/storage.bicep' = {
//   name: lastorage_name
//   params: {
//     resourceTags: resourceTags
//     location: location
//     name: lastorage_name
//     vnetId: network.outputs.vnetId
//     privateLinkSubnetId: network.outputs.privateLinkSubnetId
//   }
// }

module appconfig 'appconfig/appconfigPE.bicep' = {
  name: 'acs-${suffix}'
  params: {
    name: 'acs-${suffix}'
    location: location
    vnetId: network.outputs.vnetId
    peSubnetId: network.outputs.peSubnetId
    resourceTags: resourceTags
  }
}

module sql 'sql/sqlPE.bicep' = {
  name: 'sql-${suffix}'
  params: {
    sqlAdministratorLogin: 'dbadmin'
    sqlname: 'sql${suffixnh}'
    dbname: 'db${suffixnh}'
    location: location
    vnetId: network.outputs.vnetId
    peSubnetId: network.outputs.peSubnetId
  }
}

module func 'appservice/funcPE.bicep' = {
  name: 'func${suffixnh}'
  params: {
    functionAppPlanName: 'asp-func-${suffix}'
    functionAppName: 'func${suffixnh}'
    functionStorageAccountName: 'strfnc${suffixnh}'
    location: location
    vnetId: network.outputs.vnetId
    peSubnetId: network.outputs.peSubnetId
    funcBeSubnetId: network.outputs.funcBeSubnetId
    workspaceId: workspaceId
    resourceTags: resourceTags
  }
}
