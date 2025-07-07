#!/bin/bash
# OIDC認証用サービスプリンシパルとFederated Credentialのセットアップスクリプト
# Usage: bash setup-oidc-github-sp.sh <SUBSCRIPTION_ID> <TENANT_ID> <GITHUB_ORG> <GITHUB_REPO> <SP_NAME>

set -e

SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-$1}" # AzureサブスクリプションID
TENANT_ID="${TENANT_ID:-$2}" # Azure ADテナントID
GITHUB_ORG="${GITHUB_ORG:-${GITHUB_REPOSITORY_OWNER:-$3}}" # GitHub組織/ユーザー名
GITHUB_REPO="${GITHUB_REPO:-${GITHUB_REPOSITORY##*/}}" # GitHubリポジトリ名
SP_NAME="${SP_NAME:-$5}" # サービスプリンシパル名

if [ -z "$SUBSCRIPTION_ID" ] || [ -z "$TENANT_ID" ] || [ -z "$GITHUB_ORG" ] || [ -z "$GITHUB_REPO" ] || [ -z "$SP_NAME" ]; then
  echo "Usage: $0 <SUBSCRIPTION_ID> <TENANT_ID> <GITHUB_ORG> <GITHUB_REPO> <SP_NAME>"
  echo "実行時の変数を指定して再度実行してください。"
  exit 1
fi

# 1. サービスプリンシパル作成（OIDC用）
az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role Contributor \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --sdk-auth

# 2. サービスプリンシパルのappId取得
echo "Fetching appId for SP..."
APP_ID=$(az ad sp list --display-name "$SP_NAME" --query "[0].appId" -o tsv)

# 3. Federated Credential作成（GitHub OIDC用）
az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters '{
    "name": "github-oidc",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'"$GITHUB_ORG"'/'"$GITHUB_REPO"':ref:refs/heads/*",
    "description": "GitHub Actions OIDC federated credential",
    "audiences": ["api://AzureADTokenExchange"]
  }'

echo "---"
echo "OIDC SP作成完了。GitHub secretに以下を設定してください:"
echo "AZURE_CLIENT_ID: $APP_ID"
echo "AZURE_TENANT_ID: $TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo "---"
