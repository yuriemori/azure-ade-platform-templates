# Azureベース：セキュア＆スケーラブルなWebアプリケーションアーキテクチャ

## 構成要素と設計ポイント

- **フロントエンド/バックエンド**: それぞれAzure App Service（コンテナイメージ）でホスト
- **データベース**: Azure SQL Database（Managed Identity経由でアクセス、シークレットレス運用）
- **シークレット管理**: Azure Key Vault
- **CI/CD**: GitHub Actions（Managed IdentityでKey VaultやDBに安全にアクセス）
- **監視**: Application Insights
- **可用性・スケール**: App Serviceの自動スケール機能、SQL DBの冗長化
- **ネットワーク/セキュリティ**: Application Gateway（WAF有効）、VNet統合、NSG/Private Endpoint活用

---

## アーキテクチャ図（Mermaid.js）

```mermaid
flowchart TD
    subgraph Internet
        User[ユーザー]
    end

    User --> AGW[Application Gateway<br/>(WAF有効, TLS終端)]

    AGW --> FE[Front-end App Service<br/>(Container)]
    AGW --> BE[Back-end App Service<br/>(Container)]

    FE -- Managed Identity --> KV[Azure Key Vault]
    BE -- Managed Identity --> KV

    FE -- Managed Identity --> SQL[Azure SQL DB]
    BE -- Managed Identity --> SQL

    FE -- Logs --> AI[Application Insights]
    BE -- Logs --> AI

    subgraph Azure
        AGW
        FE
        BE
        SQL
        KV
        AI
    end

    subgraph DevOps
        GH[GitHub Actions]
        GH -- Managed Identity --> KV
        GH -- Managed Identity --> SQL
    end

    User -.->|HTTPS| AGW
    AGW -.->|VNet統合| FE
    AGW -.->|VNet統合| BE
    FE -.->|Private Endpoint| SQL
    BE -.->|Private Endpoint| SQL
    AGW -.->|Private Endpoint| KV
```

---

## ベストプラクティス要点

- **セキュリティ**
  - App Service/CI/CDともにManaged Identityを利用し、シークレットレスでKey VaultやDBにアクセス
  - Application GatewayでWAF/TLS終端、バックエンドもTLS推奨
  - NSG/Private Endpointでネットワーク境界を強化
  - Key Vault/SQL DBはパブリックアクセス禁止
- **可用性・スケール**
  - App Serviceの自動スケール設定
  - SQL DBのGeo冗長化/自動フェールオーバー
- **監視・運用**
  - Application Insightsでアプリ監視
  - Azure Monitor/Log Analyticsで全体監視
- **CI/CD**
  - GitHub ActionsでManaged Identityを利用し、Key Vault/SQL DBに安全にアクセス

---

### 参考リンク
- [App Service ベストプラクティス](https://learn.microsoft.com/en-us/azure/well-architected/service-guides/app-service-web-apps#security)
- [Application Gateway ベストプラクティス](https://learn.microsoft.com/en-us/azure/well-architected/service-guides/azure-application-gateway#security)
- [Key Vault 参照の利用](https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references#grant-your-app-access-to-a-key-vault)
- [Managed Identity の活用](https://learn.microsoft.com/en-us/azure/app-service/overview-managed-identity)

---
