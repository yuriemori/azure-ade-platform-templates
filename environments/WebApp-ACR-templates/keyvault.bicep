// keyvault.bicep: Azure Key Vault + Private Endpoint
param envName string
param vnetId string
param location string

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: 'yuriemori-${envName}-kv'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [] // 必要に応じて追加
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: vnetId
        }
      ]
    }
    enablePurgeProtection: true
    enableSoftDelete: true
  }
}

output keyVaultId string = keyVault.id
