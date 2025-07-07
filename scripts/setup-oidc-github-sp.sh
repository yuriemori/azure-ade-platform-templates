#!/bin/bash
# OIDC認証用サービスプリンシパルとFederated Credentialのセットアップスクリプト
# Usage: bash setup-oidc-github-sp.sh <SUBSCRIPTION_ID> <TENANT_ID> <GITHUB_ORG> <GITHUB_REPO> <SP_NAME>

set -e

SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-$1}" # AzureサブスクリプションID: GitHubのvariableから取得
TENANT_ID="${TENANT_ID:-$2}" # Azure ADテナントID: GitHubのvariableから取得
GITHUB_ORG="${GITHUB_ORG:-${GITHUB_REPOSITORY_OWNER:-$3}}" #実行時に自動で設定される
GITHUB_REPO="${GITHUB_REPO:-${GITHUB_REPOSITORY##*/}}" #実行時に自動で設定される
SP_NAME="${SP_NAME:-$5}" # サービスプリンシパル名: GitHubのvariableから取得

if [ -z "$SUBSCRIPTION_ID" ] || [ -z "$TENANT_ID" ] || [ -z "$GITHUB_ORG" ] || [ -z "$GITHUB_REPO" ] || [ -z "$SP_NAME" ]; then
  echo "Usage: $0 <SUBSCRIPTION_ID> <TENANT_ID> <GITHUB_ORG> <GITHUB_REPO> <SP_NAME>"
  echo "または、SUBSCRIPTION_ID, TENANT_ID, SP_NAME を環境変数で設定してください。"
  echo "GITHUB_ORG, GITHUB_REPO はGitHub Actions実行時は自動で設定されます。"
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
    "description": "GitHub Actions OIDC federated credential"
  }'

echo "---"
echo "OIDC SP作成完了。GitHub Actionsのazure/login@v1で以下を使用してください:"
echo "client-id: $APP_ID"
echo "tenant-id: $TENANT_ID"
echo "subscription-id: $SUBSCRIPTION_ID"
echo "---"
