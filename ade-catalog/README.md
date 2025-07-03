# Azure Deployment Environments カタログ

このカタログには、Azure Deployment Environments (ADE) の環境定義が含まれており、開発者が完全なアプリケーションインフラストラクチャをセルフサービスでデプロイできます。

## カタログ構造

```
ade-catalog/
├── README.md                    # このファイル
├── ADE-SETUP.md                # 完全なセットアップガイド
└── environment-definitions/     # 環境定義
    └── secure-webapp/          # セキュアなWebアプリケーション環境
        └── main.bicep         # Infrastructure as Code テンプレート
```

## 環境定義

### セキュアWebアプリケーション (`secure-webapp`)

Azureセキュリティのベストプラクティスに従った、完全な本番対応Webアプリケーション環境です。

**コンポーネント:**
- フロントエンドおよびバックエンドApp Services（コンテナ化）
- プライベート接続でのAzure SQL Database
- シークレット管理のためのAzure Key Vault
- Web Application FirewallでのApplication Gateway
- 監視のためのApplication Insights
- 適切にセグメント化されたVirtual Network
- パスワードレス認証のためのManaged Identity

**使用例:**
- フルスタックWebアプリケーション
- マイクロサービスアーキテクチャ
- セキュアなエンタープライズアプリケーション
- 開発、ステージング、本番環境

## はじめに

1. **セットアップ**: [ADE-SETUP.md](./ADE-SETUP.md) ガイドに従ってAzure Deployment Environmentsを設定
2. **デプロイ**: Developer PortalまたはAzure CLIを使用して環境を作成
3. **カスタマイズ**: 特定の要件に合わせてテンプレートを変更

## 主要機能

### セキュリティファースト
- すべてのサービス認証にManaged Identity
- データベースとKey Vaultアクセス用のプライベートエンドポイント
- ネットワーク分離のためのVNet統合
- Web Application Firewall保護
- きめ細かなアクセス制御のためのRBAC

### 本番対応
- 自動スケーリング機能
- 高可用性設定
- 包括的な監視とログ記録
- 災害復旧の考慮
- コスト最適化機能

### 開発者フレンドリー
- Developer Portalを通じたセルフサービスデプロイメント
- 異なる環境用のパラメータ化テンプレート
- 明確なドキュメントと例
- 一貫した命名規則

## テンプレート標準

このカタログのすべての環境定義は以下の標準に従います：

### ファイル構造
- `main.bicep`: プライマリインフラストラクチャテンプレート

### 命名規則
- リソースは環境プレフィックスで一貫した命名を使用
- 一意の接尾辞により命名競合を防止
- 明確なリソースタイプ識別

### セキュリティ要件
- サービス認証にManaged Identity
- 機密サービス用のプライベートエンドポイント
- ネットワークセグメンテーションと分離
- Key Vaultを通じたシークレット管理
- 該当する場所でのHTTPS強制

## カスタマイズガイド

### 新しい環境定義の追加

1. `environment-definitions/` 下に新しいディレクトリを作成
2. 必要なファイルを追加: `main.bicep`
3. 命名とセキュリティ標準に従う
4. 開発環境でデプロイメントをテスト
5. カタログドキュメントを更新

### 既存テンプレートの変更

1. 必要な変更でBicepテンプレートを更新
2. ドキュメントを更新
3. 変更を徹底的にテスト
4. 適切にバージョン管理

## ベストプラクティス

### 開発
- すべてのリソースにinfrastructure as codeを使用
- 適切なエラーハンドリングを実装
- Azure命名規則に従う
- 一貫したタグ戦略を使用

### セキュリティ
- 利用可能なすべてのセキュリティ機能を有効化
- 最小権限アクセス原則を使用
- 定期的なセキュリティレビューと更新
- セキュリティ脆弱性の監視

### 運用
- 包括的な監視を実装
- 重要な問題のアラートを設定
- バックアップと災害復旧を計画
- 定期的なメンテナンスと更新

### コスト管理
- ワークロード要件に応じたリソースSKUの最適化
- 適切な場所での自動スケーリングの実装
- コストしきい値の監視とアラート
- 定期的なコスト最適化レビュー

## リソース

- [Azure Deployment Environments ドキュメント](https://learn.microsoft.com/ja-jp/azure/deployment-environments/)
- [Azure Bicep ドキュメント](https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/bicep/)
- [Azureセキュリティのベストプラクティス](https://learn.microsoft.com/ja-jp/azure/security/)
- [Azure Well-Architected Framework](https://learn.microsoft.com/ja-jp/azure/well-architected/)

## バージョン履歴

- **v1.0.0**: セキュアWebアプリケーション環境の初回リリース
  - 完全なインフラストラクチャテンプレート
  - セキュリティベストプラクティスの実装
  - 包括的なドキュメント
  - セットアップとデプロイメントガイド