
// main.bicep: 全体のエントリーポイント

param envName string
var location = 'japaneast'

@secure()
param sqlAdminPassword string

module network 'network.bicep' = {
  name: 'network'
  params: {
    envName: envName
    location: location
  }
}

module acr 'acr.bicep' = {
  name: 'acr'
  params: {
    envName: envName
    location: location
  }
}

module keyvault 'keyvault.bicep' = {
  name: 'keyvault'
  params: {
    envName: envName
    vnetId: network.outputs.subnetId
    location: location
  }
}

module sql 'sql.bicep' = {
  name: 'sql'
  params: {
    envName: envName
    vnetId: network.outputs.vnetId
    location: location
    sqlAdminPassword: sqlAdminPassword
  }
}

module appInsights 'appInsights.bicep' = {
  name: 'appInsights'
  params: {
    envName: envName
    location: location
  }
}

module appService 'appService.bicep' = {
  name: 'appService'
  params: {
    envName: envName
    keyVaultId: keyvault.outputs.keyVaultId
    sqlServerName: sql.outputs.sqlServerName
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    appServiceSubnetId: network.outputs.appServiceSubnetId
    acrLoginServer: acr.outputs.acrLoginServer
    location: location
  }
}
