# Azure Deployment Environments セットアップガイド

このガイドでは、Azure Deployment Environments (ADE) を使用してセキュアWebアプリケーション環境をデプロイするための完全なセットアップ手順を説明します。

## 概要

Azure Deployment Environmentsは、開発チームがアプリケーションインフラストラクチャのセルフサービスデプロイメントを可能にします。このセットアップでは、セキュアWebアプリケーション環境テンプレートを含むカタログを作成します。

## 前提条件

- OwnerまたはContributor権限を持つAzureサブスクリプション
- Azure CLIまたはAzure PowerShellがインストール済み
- このカタログを含むGitリポジトリ（このリポジトリ）

## ステップ1: Dev Centerの作成

### Azureポータルを使用

1. Azureポータルに移動
2. "Dev centers" を検索して新しいDev Centerを作成
3. 必要な情報を入力：
   - **名前**: `webapp-devcenter`（または任意の名前）
   - **サブスクリプション**: 対象のサブスクリプション
   - **リソースグループ**: 新規作成または既存を選択
   - **場所**: Japan East（または任意のリージョン）
4. "Review + Create" をクリックし、次に "Create" をクリック

### Azure CLIを使用

```bash
# 変数を設定
SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP="rg-webapp-devcenter"
DEVCENTER_NAME="webapp-devcenter"
LOCATION="japaneast"

# リソースグループを作成
az group create --name $RESOURCE_GROUP --location $LOCATION

# Dev Centerを作成
az devcenter admin devcenter create \
  --resource-group $RESOURCE_GROUP \
  --name $DEVCENTER_NAME \
  --location $LOCATION
```

## ステップ2: カタログの作成

### Azureポータルを使用

1. Dev Centerで「カタログ」に移動
2. 「追加」をクリックして新しいカタログを作成
3. カタログを設定：
   - **名前**: `secure-webapp-catalog`
   - **Git Clone URI**: `https://github.com/yuriemori/mcp_trial.git`
   - **ブランチ**: `main`
   - **パス**: `/ade-catalog`
4. 「追加」をクリック

### Azure CLIを使用

```bash
# カタログを作成
az devcenter admin catalog create \
  --resource-group $RESOURCE_GROUP \
  --dev-center $DEVCENTER_NAME \
  --name "secure-webapp-catalog" \
  --git-hub-repo-url "https://github.com/yuriemori/mcp_trial.git" \
  --git-hub-branch "main" \
  --git-hub-path "/ade-catalog"
```

## ステップ3: プロジェクトの作成

### Azureポータルを使用

1. Dev Centerで「プロジェクト」に移動
2. 「作成」をクリックして新しいプロジェクトを作成
3. プロジェクトを設定：
   - **名前**: `webapp-project`
   - **説明**: `Webアプリケーション開発プロジェクト`
   - **リソースグループ**: デプロイされた環境用のリソースグループを選択または作成
4. 「作成」をクリック

### Azure CLIを使用

```bash
PROJECT_NAME="webapp-project"
PROJECT_RG="rg-webapp-environments"

# 環境用のリソースグループを作成
az group create --name $PROJECT_RG --location $LOCATION

# プロジェクトを作成
az devcenter admin project create \
  --resource-group $RESOURCE_GROUP \
  --name $PROJECT_NAME \
  --dev-center-id "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DevCenter/devcenters/$DEVCENTER_NAME" \
  --description "Webアプリケーション開発プロジェクト"
```

## ステップ4: 環境タイプの作成

### Azureポータルを使用

1. Dev Centerで「環境タイプ」に移動
2. 「追加」をクリックして新しい環境タイプを作成
3. 環境タイプを設定：
   - **名前**: `development`
   - **説明**: `Webアプリケーション用開発環境`
4. 「追加」をクリック
5. 追加の環境タイプ（`staging`、`production`）についても繰り返し

### Azure CLIを使用

```bash
# 環境タイプを作成
az devcenter admin environment-type create \
  --resource-group $RESOURCE_GROUP \
  --dev-center $DEVCENTER_NAME \
  --name "development"

az devcenter admin environment-type create \
  --resource-group $RESOURCE_GROUP \
  --dev-center $DEVCENTER_NAME \
  --name "staging"

az devcenter admin environment-type create \
  --resource-group $RESOURCE_GROUP \
  --dev-center $DEVCENTER_NAME \
  --name "production"
```

## ステップ5: プロジェクト環境タイプの設定

### Azureポータルを使用

1. プロジェクトに移動
2. 「環境タイプ」に移動
3. 「追加」をクリックして上記で作成した環境タイプを選択
4. 各環境タイプについて以下を設定：
   - **デプロイメントサブスクリプション**: 環境用の対象サブスクリプション
   - **デプロイメントリソースグループ**: デプロイされたリソース用のリソースグループ
   - **作成者ロール割り当て**: 環境作成者のロール
   - **ユーザーロール割り当て**: 環境ユーザーのロール

### Azure CLIを使用

```bash
# プロジェクト環境タイプを設定
az devcenter admin project-environment-type create \
  --resource-group $RESOURCE_GROUP \
  --project-name $PROJECT_NAME \
  --environment-type-name "development" \
  --deployment-target-id "/subscriptions/$SUBSCRIPTION_ID" \
  --status "Enabled"
```

## ステップ6: ユーザー権限の割り当て

### 必要なロール

- **Dev Center Project Admin**: プロジェクトと環境タイプを管理可能
- **Deployment Environments User**: 環境の作成と管理が可能
- **DevCenter Dev Box User**: 開発者ポータルにアクセス可能

### Azureポータルを使用

1. プロジェクトに移動
2. 「アクセス制御（IAM）」に移動
3. 「ロール割り当ての追加」をクリック
4. ユーザーまたはグループに適切なロールを割り当て

### Azure CLIを使用

```bash
# ユーザーをプロジェクトに割り当て
USER_PRINCIPAL_ID="user-object-id"

az role assignment create \
  --assignee $USER_PRINCIPAL_ID \
  --role "Deployment Environments User" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DevCenter/projects/$PROJECT_NAME"
```

## ステップ7: 環境のデプロイ（開発者ワークフロー）

### Developer Portalを使用

1. https://devportal.microsoft.com に移動
2. プロジェクトを選択
3. 「新しい環境」をクリック
4. "secure-webapp" 環境定義を選択
5. パラメータを入力：
   - **環境名**: `my-webapp-dev`
   - **場所**: `japaneast`
   - **App Service Plan SKU**: `B1`（開発用）
   - **SQL Database SKU**: `Basic`（開発用）
6. 「作成」をクリック

### Azure CLIを使用

```bash
# 環境を作成
az devcenter dev environment create \
  --dev-center $DEVCENTER_NAME \
  --project-name $PROJECT_NAME \
  --environment-name "my-webapp-dev" \
  --environment-type "development" \
  --catalog-name "secure-webapp-catalog" \
  --environment-definition-name "secure-webapp" \
  --parameters '{
    "environmentName": {"value": "mywebapp"},
    "location": {"value": "japaneast"},
    "appServicePlanSku": {"value": "B1"},
    "sqlDatabaseSku": {"value": "Basic"},
    "enableApplicationGateway": {"value": false}
  }'
```

## ステップ8: デプロイメントの検証

デプロイメント後、以下のリソースが作成されていることを確認：

1. **リソースグループ**: 環境プレフィックス付きの名前
2. **App Services**: フロントエンドとバックエンドアプリケーション
3. **SQL Database**: プライベートエンドポイント付き
4. **Key Vault**: シークレットと適切なアクセスポリシー付き
5. **Virtual Network**: 適切なサブネット設定
6. **Application Gateway**: 有効にした場合

## トラブルシューティング

### よくある問題

1. **カタログ同期の失敗**
   - リポジトリのURLとブランチを確認
   - カタログディレクトリへのパスを確認
   - manifest.yamlが有効であることを確認

2. **権限エラー**
   - ユーザーが適切なロールを持っていることを確認
   - サブスクリプション権限を確認
   - リソースグループアクセスを検証

3. **デプロイメントの失敗**
   - ポータルでデプロイメントログを確認
   - パラメータ値を確認
   - クォータ制限を確認

### ログと監視

- **アクティビティログ**: デプロイメントアクティビティを表示
- **デプロイメント履歴**: 詳細なデプロイメントログを確認
- **リソースヘルス**: リソースステータスを監視

## ベストプラクティス

1. **環境命名**: 一貫した命名規則を使用
2. **リソースタグ**: コスト追跡とガバナンスのためのタグを適用
3. **セキュリティ**: アクセス権限を定期的にレビュー
4. **コスト管理**: 環境コストを監視し、予算を設定
5. **ライフサイクル**: 環境クリーンアップポリシーを実装

## 次のステップ

1. 特定のニーズに合わせて環境テンプレートをカスタマイズ
2. 異なるアプリケーションタイプ用の追加環境定義を追加
3. GitHub ActionsでCI/CD統合を実装
4. デプロイされた環境の監視とアラートを設定
5. 環境管理ポリシーとガバナンスを作成

## リソース

- [Azure Deployment Environments ドキュメント](https://learn.microsoft.com/ja-jp/azure/deployment-environments/)
- [Bicep言語リファレンス](https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/bicep/)
- [Azure CLI リファレンス](https://learn.microsoft.com/ja-jp/cli/azure/)
- [ADEカタログのベストプラクティス](https://learn.microsoft.com/ja-jp/azure/deployment-environments/)