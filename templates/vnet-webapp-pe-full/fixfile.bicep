param location string = resourceGroup().location

@description('Specifies the Azure Function hosting plan SKU.')
@allowed([
  'EP1'
  'EP2'
  'EP3'
])
param functionAppPlanSku string = 'EP1'
@description('Specifies the OS used for the Azure Function hosting plan.')
@allowed([
  'Windows'
  'Linux'
])
param functionPlanOS string = 'Windows'
param version string = '7'
param domain string = 'ecloud'
param project string = 'sol${version}'
param shortloc string = 'eus'
param env string = 'poc'

var suffix = '${domain}-${project}-${env}-${shortloc}'
var suffixnh = '${domain}${project}${env}${shortloc}'
var isReserved = (functionPlanOS == 'Linux') ? true : false
var functionAppPlanName = 'asp-func-${suffix}'
var functionAppName = 'func${suffixnh}'

resource plan 'Microsoft.Web/serverfarms@2021-01-01' = {
  location: location
  name: functionAppPlanName
  sku: {
    name: functionAppPlanSku
    tier: 'ElasticPremium'
    size: functionAppPlanSku
    family: 'EP'
  }
  kind: 'elastic'
  properties: {
    maximumElasticWorkerCount: 20
    reserved: isReserved
  }  
}

resource functionApp 'Microsoft.Web/sites@2021-01-01' = {
  location: location
  name: functionAppName
  kind: isReserved ? 'functionapp,linux' : 'functionapp'
  properties: {
    serverFarmId: plan.id
    reserved: isReserved    
    siteConfig: {
      functionsRuntimeScaleMonitoringEnabled: true
      linuxFxVersion: isReserved ? 'dotnet|3.1' : json('null')
    }
  }
}
