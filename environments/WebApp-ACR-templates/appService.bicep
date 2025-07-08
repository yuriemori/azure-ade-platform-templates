// appService.bicep: App Service (Front/Back), Managed Identity, VNet統合
param envName string
param keyVaultId string
param sqlServerName string
param appInsightsInstrumentationKey string
param appServiceSubnetId string
param acrLoginServer string
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
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
      ]
      linuxFxVersion: 'DOCKER|${acrLoginServer}/frontend:latest'
      vnetRouteAllEnabled: true
    }
  }
}

// VNet Integration for Frontend
resource feVnetConnection 'Microsoft.Web/sites/networkConfig@2022-03-01' = {
  name: 'virtualNetwork'
  parent: feApp
  properties: {
    subnetResourceId: appServiceSubnetId
    swiftSupported: true
  }
}

// フロントエンド用デプロイスロット（例: staging）
resource feAppStagingSlot 'Microsoft.Web/sites/slots@2022-03-01' = {
  name: 'staging'
  parent: feApp
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
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
      ]
      linuxFxVersion: 'DOCKER|${acrLoginServer}/frontend:staging'
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
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
      ]
      linuxFxVersion: 'DOCKER|${acrLoginServer}/backend:latest'
      vnetRouteAllEnabled: true
    }
  }
}

// VNet Integration for Backend
resource beVnetConnection 'Microsoft.Web/sites/networkConfig@2022-03-01' = {
  name: 'virtualNetwork'
  parent: beApp
  properties: {
    subnetResourceId: appServiceSubnetId
    swiftSupported: true
  }
}

// バックエンド用デプロイスロット（例: staging）
resource beAppStagingSlot 'Microsoft.Web/sites/slots@2022-03-01' = {
  name: 'staging'
  parent: beApp
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
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
      ]
      linuxFxVersion: 'DOCKER|${acrLoginServer}/backend:staging'
      vnetRouteAllEnabled: true
    }
  }
}
