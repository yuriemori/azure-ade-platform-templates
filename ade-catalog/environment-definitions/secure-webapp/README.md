# セキュアWebアプリケーション環境

このAzure Deployment Environments定義は、Azureベストプラクティスに従った完全で安全かつスケーラブルなWebアプリケーションインフラストラクチャを作成します。

## アーキテクチャ

このテンプレートは以下のコンポーネントをデプロイします：

### コアインフラストラクチャ
- **仮想ネットワーク**: App Services、Application Gateway、プライベートエンドポイント用のセグメント化されたサブネット
- **App Service プラン**: コンテナ化されたアプリケーションをサポートするLinuxベースのプラン
- **フロントエンド App Service**: コンテナベースのフロントエンドアプリケーション
- **バックエンド App Service**: コンテナベースのバックエンドAPI
- **Azure SQL Database**: プライベートエンドポイント接続を持つマネージドデータベース
- **Azure Key Vault**: RBACを使用した集中的なシークレット管理
- **Application Insights**: アプリケーションパフォーマンス監視
- **Log Analytics ワークスペース**: 集中ログ記録と監視

### セキュリティ機能
- **マネージドID**: すべてのサービスでパスワードレス認証
- **プライベートエンドポイント**: SQL DatabaseとKey Vaultへのプライベート接続
- **VNet統合**: 仮想ネットワークと統合されたApp Services
- **Application Gateway**: Web Application Firewall (WAF) 保護
- **RBAC**: Key Vaultアクセス用のロールベースアクセス制御
- **HTTPS のみ**: すべてのWebトラフィックでHTTPS強制

### ネットワークセキュリティ
- 異なるサービス層用の専用サブネット
- プライベートエンドポイント解決用のプライベートDNSゾーン
- ネットワークセキュリティグループ（サブネット委任によって暗示）
- SQL DatabaseとKey Vaultでパブリックアクセス無効化

## パラメータ

| パラメータ | 説明 | デフォルト | 必須 |
|-----------|------|----------|------|
| `environmentName` | すべてのリソースの名前プレフィックス | - | はい |
| `location` | デプロイメント用のAzureリージョン | japaneast | はい |
| `appServicePlanSku` | App Service Planの価格ティア | P1v3 | いいえ |
| `sqlDatabaseSku` | SQL Databaseの価格ティア | S1 | いいえ |
| `enableApplicationGateway` | WAF付きApplication Gatewayをデプロイ | true | いいえ |
| `containerImageTag` | アプリケーション用のコンテナイメージタグ | latest | いいえ |

## デプロイメント

この環境はAzure Deployment Environments (ADE)を通じてデプロイされるように設計されています。以下の手順が必要です：

1. Dev Centerでこのカタログを登録
2. このテンプレートを指すエンバイロメント定義を作成
3. Developer PortalまたはAzure CLIを通じてデプロイ

### 前提条件

- 適切な権限を持つAzureサブスクリプション
- このカタログで構成されたDev Center
- コンテナレジストリで利用可能なコンテナイメージ（実際のアプリケーション用）

## デプロイ後の設定

デプロイ後、以下の手動手順が必要な場合があります：

1. **コンテナイメージ**: 実際のコンテナイメージでApp Servicesを更新
2. **SSL証明書**: Application Gateway用のSSL証明書を設定
3. **データベーススキーマ**: データベーススキーマとデータを初期化
4. **アプリケーション設定**: アプリケーション設定と接続文字列を更新
5. **DNS設定**: カスタムドメインをApplication Gatewayに設定

## 監視

環境には包括的な監視が含まれています：

- **Application Insights**: アプリケーションパフォーマンスとユーザー分析
- **Log Analytics**: すべてのAzureリソースの集中ログ記録
- **Azure Monitor**: インフラストラクチャメトリクスとアラート

## 実装されたセキュリティベストプラクティス

- パスワードレス認証のためのマネージドID
- データベースとkey vault接続のためのプライベートエンドポイント
- App ServicesのVNet統合
- 外部トラフィック保護のためのWeb Application Firewall
- きめ細かいアクセス制御のためのRBAC
- 適切なアクセスポリシーでKey Vaultに保存されたシークレット
- すべてのWebトラフィックでHTTPS強制
- 機密リソースでパブリックアクセス無効化

## スケーリングと高可用性

- 自動スケーリングをサポートするApp Service Plan
- 組み込み高可用性を持つSQL Database
- ロードバランシングを提供するApplication Gateway
- マルチゾーンデプロイメント機能（リージョンによる）

## コスト最適化

- 異なる環境（dev/test/prod）用の設定可能なSKU
- フロントエンドとバックエンドで共有されるApp Service Plan
- ワークロード要件に基づく効率的なリソースサイジング

## カスタマイゼーション

このテンプレートは以下によってカスタマイズできます：

- 異なるパフォーマンス要件に応じたSKUの変更
- マイクロサービスアーキテクチャ用の追加App Servicesの追加
- CI/CD用のAzure Container Registryとの統合
- グローバルコンテンツ配信用のAzure CDNの追加
- APIガバナンス用のAzure API Managementの実装

## サポート

この環境定義に関する問題や質問については、リポジトリドキュメントを参照するか、プラットフォームチームにお問い合わせください。