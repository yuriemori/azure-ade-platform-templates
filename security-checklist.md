# セキュリティ設定チェックリスト

このファイルは `main.bicep` のセキュリティ検証チェックリストです。

## 現在の main.bicep セキュリティ評価

### ✅ 実装済み (Good Practices)

- **パラメータセキュリティ**: `@secure()` デコレータを使用してSQLパスワードを保護
- **モジュール化**: 機能別にBicepファイルを分離し、保守性を向上
- **Managed Identity**: Key VaultとSQL Databaseのアクセスに使用予定

### ⚠️ 改善が必要 (Security Gaps)

1. **ハードコードされた場所**
   ```bicep
   var location = 'japaneast'  // ❌ ハードコード
   ```
   **推奨**: パラメータ化
   ```bicep
   @allowed(['japaneast', 'eastus', 'westeurope'])
   param location string = 'japaneast'
   ```

2. **リソース命名規則**
   ```bicep
   name: 'yuriemori-${envName}-kv'  // ❌ ユーザー名ハードコード
   ```
   **推奨**: 
   ```bicep
   name: '${resourcePrefix}-${envName}-kv'
   ```

3. **タグの未実装**
   ```bicep
   // ❌ 現在タグなし
   ```
   **推奨**:
   ```bicep
   var commonTags = {
     Environment: envName
     Project: 'WebApp-ACR'
     Owner: 'platform-team'
     CostCenter: 'IT-001'
   }
   ```

4. **バージョン管理**
   ```bicep
   // ❌ APIバージョンが明示的でない箇所あり
   ```

## セキュリティ強化のための具体的修正案

### 1. パラメータセキュリティ強化

```bicep
@description('Environment name (dev, staging, prod)')
@allowed(['dev', 'staging', 'prod'])
param envName string

@description('Azure region for resource deployment')  
@allowed(['japaneast', 'eastus', 'westeurope'])
param location string = 'japaneast'

@description('Resource prefix for naming')
@minLength(3)
@maxLength(10)
param resourcePrefix string

@secure()
@description('SQL Server administrator password')
@minLength(12)
param sqlAdminPassword string
```

### 2. 必須タグの実装

```bicep
var mandatoryTags = {
  Environment: envName
  Project: 'WebApp-ACR'
  ManagedBy: 'AzureDevOps'
  CreatedDate: utcNow('yyyy-MM-dd')
  Version: '1.0'
}
```

### 3. セキュリティ設定の明示化

```bicep
var securitySettings = {
  keyVault: {
    enableSoftDelete: true
    enablePurgeProtection: true
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
  sql: {
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    enableAdvancedDataSecurity: true
  }
  appService: {
    httpsOnly: true
    minTlsVersion: '1.2'
    enableManagedIdentity: true
  }
}
```

## セキュリティテスト項目

### 自動テスト項目
- [ ] Key Vault: Soft Delete有効化確認
- [ ] Key Vault: パブリックアクセス無効化確認  
- [ ] SQL Database: TLS 1.2最小バージョン確認
- [ ] SQL Database: パブリックアクセス無効化確認
- [ ] App Service: HTTPS Only設定確認
- [ ] App Service: Managed Identity有効化確認
- [ ] 全リソース: 必須タグ設定確認

### 手動検証項目  
- [ ] Private Endpoint設定検証
- [ ] Network Security Group ルール確認
- [ ] Azure Policy準拠状況確認
- [ ] アクセス権限最小化確認