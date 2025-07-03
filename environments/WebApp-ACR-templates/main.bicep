// main.bicep: 全体のエントリーポイント
var location = 'japaneast'
param envName string

module network 'network.bicep' = {
  name: 'network'
  params: {
    envName: envName
    location: location
  }
}

module keyvault 'keyvault.bicep' = {
  name: 'keyvault'
  params: {
    envName: envName
    location: location
    vnetId: network.outputs.vnetId
  }
}

module sql 'sql.bicep' = {
  name: 'sql'
  params: {
    envName: envName
    location: location
    vnetId: network.outputs.vnetId
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
    location: location
    keyVaultId: keyvault.outputs.keyVaultId
    sqlServerName: sql.outputs.sqlServerName
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    vnetId: network.outputs.vnetId
  }
}
