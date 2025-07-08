#!/bin/bash
# This script sets up an Azure Service Principal (SP) for GitHub Actions OIDC authentication.
# It creates a service principal with Contributor role and configures federated credentials for OIDC.
# Usage: bash setup-oidc-github-sp.sh <SUBSCRIPTION_ID> <TENANT_ID> <GITHUB_ORG> <GITHUB_REPO> <SP_NAME>

set -e

SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-$1}" # Azure subscription ID
TENANT_ID="${TENANT_ID:-$2}" # Azure tenant ID
GITHUB_ORG="${GITHUB_ORG:-${GITHUB_REPOSITORY_OWNER:-$3}}" # GitHub organization/user name
GITHUB_REPO="${GITHUB_REPO:-${GITHUB_REPOSITORY##*/}}" # GitHub repository name
SP_NAME="${SP_NAME:-$5}" # Service Principal name

if [ -z "$SUBSCRIPTION_ID" ] || [ -z "$TENANT_ID" ] || [ -z "$GITHUB_ORG" ] || [ -z "$GITHUB_REPO" ] || [ -z "$SP_NAME" ]; then
  echo "Usage: $0 <SUBSCRIPTION_ID> <TENANT_ID> <GITHUB_ORG> <GITHUB_REPO> <SP_NAME>"
  echo "re-run with the required variables set."
  exit 1
fi

# 1. Create a service principal with Contributor role
az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role Contributor \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --sdk-auth

# 2. Get the service principal's appId
echo "Fetching appId for SP..."
APP_ID=$(az ad sp list --display-name "$SP_NAME" --query "[0].appId" -o tsv)

# 3. Create Federated Credential作成（for push/merge to main）
az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters '{
    "name": "github-oidc-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'"$GITHUB_ORG"'/'"$GITHUB_REPO"':ref:refs/heads/*",
    "description": "GitHub Actions OIDC federated credential for main branch",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# 4. Create Federated Credential（for pull_request）
az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters '{
    "name": "github-oidc-pr",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'"$GITHUB_ORG"'/'"$GITHUB_REPO"':pull_request",
    "description": "GitHub Actions OIDC federated credential for PR events",
    "audiences": ["api://AzureADTokenExchange"]
  }'

echo "---"
echo "Finished setting up OIDC for GitHub Actions. Please set the following in your GitHub secrets:"
echo "AZURE_CLIENT_ID: $APP_ID"
echo "AZURE_TENANT_ID: $TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo "---"