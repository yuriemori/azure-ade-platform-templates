# Azure Deployment Environments カタログ利用手順

このドキュメントは、`WebApp-with-ACR Environment` カタログをAzure Deployment Environments (ADE) で利用し、Webアプリケーション環境をセルフサービスでデプロイするための手順をまとめたものです。

---

## 1. 前提条件
- Azureサブスクリプションとリソースグループが作成済み
- Azure Deployment Environments (Dev Center/Project) が構成済み
- カタログ（このリポジトリ）がDev CenterまたはProjectに登録済み
- Azure CLI またはポータルへのアクセス権限

---

## 2. カタログ構成

```
/environments/WebApp-ACR-templates/
  ├─ main.bicep
  ├─ network.bicep
  ├─ keyvault.bicep
  ├─ sql.bicep
  ├─ appInsights.bicep
  ├─ appService.bicep
  └─ environment.yaml
```

- `environment.yaml` : ADEカタログのmanifest（環境定義ファイル）
- `main.bicep` : 全体のデプロイエントリーポイント
- その他bicepファイル : 各リソースのモジュール

---

## 3. デプロイ手順

### 3.1. Azureポータルからの利用
1. AzureポータルでDev Center > Project > Environmentsを開く
2. 「新しい環境の作成」から `WebApp-with-ACR Environment` を選択
3. `envName` など必要なパラメータを入力
4. デプロイを実行

### 3.2. Azure CLIからの利用
```sh
az devcenter dev environment create \
  --dev-center <DevCenter名> \
  --project <Project名> \
  --catalog-name <カタログ名> \
  --environment-type <EnvironmentType> \
  --definition-name "WebApp-with-ACR Environment" \
  --parameters envName=<任意の環境名>
```

---

## 4. パラメータ
| パラメータ名 | 必須 | 説明 |
|:------------|:-----|:------|
| envName     | ○    | 環境名（リソース名のプレフィックス等に利用） |

---

## 5. 注意事項・ベストプラクティス
- locationはJapan East（japaneast）で固定されています
- デプロイ後、App Service/SQL/Key Vault/ACR等が一括で構成されます
- セキュリティ・ネットワーク制御（VNet, Private Endpoint等）も自動適用
- 必要に応じてbicepやmanifestのパラメータを拡張してください

---

## 6. 参考リンク
- [Azure Deployment Environments 公式ドキュメント](https://learn.microsoft.com/ja-jp/azure/deployment-environments/)
- [カタログ設計ベストプラクティス](https://learn.microsoft.com/ja-jp/azure/deployment-environments/best-practice-catalog-structure)
- [Bicep ベストプラクティス](https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/bicep/best-practices)
