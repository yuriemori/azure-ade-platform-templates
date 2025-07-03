// appService.bicep: App Service (Front/Back), Managed Identity, VNet統合
param envName string
param keyVaultId string
param sqlServerName string
param appInsightsInstrumentationKey string
param vnetId string
param location string

resource plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${envName}-plan'
  location: location
  sku: {
    name: 'P1v2'
    tier: 'PremiumV2'
    size: 'P1v2'
    capacity: 1
  }
}

resource feApp 'Microsoft.Web/sites@2022-03-01' = {
  name: '${envName}-fe'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'KEYVAULT_URI'
          value: keyVaultId
        }
        {
          name: 'SQL_SERVER_NAME'
          value: sqlServerName
        }
      ]
      vnetRouteAllEnabled: true
    }
  }
}

// フロントエンド用デプロイスロット（例: staging）
resource feAppStagingSlot 'Microsoft.Web/sites/slots@2022-03-01' = {
  name: '${feApp.name}/staging'
  location: location
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'KEYVAULT_URI'
          value: keyVaultId
        }
        {
          name: 'SQL_SERVER_NAME'
          value: sqlServerName
        }
      ]
      vnetRouteAllEnabled: true
    }
  }
}

resource beApp 'Microsoft.Web/sites@2022-03-01' = {
  name: '${envName}-be'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'KEYVAULT_URI'
          value: keyVaultId
        }
        {
          name: 'SQL_SERVER_NAME'
          value: sqlServerName
        }
      ]
      vnetRouteAllEnabled: true
    }
  }
}

// バックエンド用デプロイスロット（例: staging）
resource beAppStagingSlot 'Microsoft.Web/sites/slots@2022-03-01' = {
  name: '${beApp.name}/staging'
  location: location
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'KEYVAULT_URI'
          value: keyVaultId
        }
        {
          name: 'SQL_SERVER_NAME'
          value: sqlServerName
        }
      ]
      vnetRouteAllEnabled: true
    }
  }
}
