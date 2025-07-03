# Azure Deployment Environments Setup Guide

This guide walks through the complete setup process for deploying the Secure Web Application Environment using Azure Deployment Environments (ADE).

## Overview

Azure Deployment Environments enables self-service deployment of application infrastructure by development teams. This setup creates a catalog containing our secure web application environment template.

## Prerequisites

- Azure subscription with Owner or Contributor permissions
- Azure CLI or Azure PowerShell installed
- Git repository containing this catalog (this repo)

## Step 1: Create Dev Center

### Using Azure Portal

1. Navigate to the Azure Portal
2. Search for "Dev centers" and create a new Dev Center
3. Fill in the required information:
   - **Name**: `webapp-devcenter` (or your preferred name)
   - **Subscription**: Your target subscription
   - **Resource Group**: Create new or select existing
   - **Location**: Japan East (or your preferred region)
4. Click "Review + Create" then "Create"

### Using Azure CLI

```bash
# Set variables
SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP="rg-webapp-devcenter"
DEVCENTER_NAME="webapp-devcenter"
LOCATION="japaneast"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Dev Center
az devcenter admin devcenter create \
  --resource-group $RESOURCE_GROUP \
  --name $DEVCENTER_NAME \
  --location $LOCATION
```

## Step 2: Create Catalog

### Using Azure Portal

1. In your Dev Center, navigate to "Catalogs"
2. Click "Add" to create a new catalog
3. Configure the catalog:
   - **Name**: `secure-webapp-catalog`
   - **Git Clone URI**: `https://github.com/yuriemori/mcp_trial.git`
   - **Branch**: `main`
   - **Path**: `/ade-catalog`
4. Click "Add"

### Using Azure CLI

```bash
# Create catalog
az devcenter admin catalog create \
  --resource-group $RESOURCE_GROUP \
  --dev-center $DEVCENTER_NAME \
  --name "secure-webapp-catalog" \
  --git-hub-repo-url "https://github.com/yuriemori/mcp_trial.git" \
  --git-hub-branch "main" \
  --git-hub-path "/ade-catalog"
```

## Step 3: Create Project

### Using Azure Portal

1. In your Dev Center, navigate to "Projects"
2. Click "Create" to create a new project
3. Configure the project:
   - **Name**: `webapp-project`
   - **Description**: `Web Application Development Project`
   - **Resource Group**: Select or create a resource group for deployed environments
4. Click "Create"

### Using Azure CLI

```bash
PROJECT_NAME="webapp-project"
PROJECT_RG="rg-webapp-environments"

# Create resource group for environments
az group create --name $PROJECT_RG --location $LOCATION

# Create project
az devcenter admin project create \
  --resource-group $RESOURCE_GROUP \
  --name $PROJECT_NAME \
  --dev-center-id "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DevCenter/devcenters/$DEVCENTER_NAME" \
  --description "Web Application Development Project"
```

## Step 4: Create Environment Type

### Using Azure Portal

1. In your Dev Center, navigate to "Environment types"
2. Click "Add" to create a new environment type
3. Configure the environment type:
   - **Name**: `development`
   - **Description**: `Development environment for web applications`
4. Click "Add"
5. Repeat for additional environment types (`staging`, `production`)

### Using Azure CLI

```bash
# Create environment types
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

## Step 5: Configure Project Environment Types

### Using Azure Portal

1. Navigate to your Project
2. Go to "Environment types"
3. Click "Add" and select the environment types created above
4. For each environment type, configure:
   - **Deployment subscription**: Target subscription for environments
   - **Deployment resource group**: Resource group for deployed resources
   - **Creator role assignments**: Roles for environment creators
   - **User role assignments**: Roles for environment users

### Using Azure CLI

```bash
# Configure project environment type
az devcenter admin project-environment-type create \
  --resource-group $RESOURCE_GROUP \
  --project-name $PROJECT_NAME \
  --environment-type-name "development" \
  --deployment-target-id "/subscriptions/$SUBSCRIPTION_ID" \
  --status "Enabled"
```

## Step 6: Assign User Permissions

### Required Roles

- **Dev Center Project Admin**: Can manage projects and environment types
- **Deployment Environments User**: Can create and manage environments
- **DevCenter Dev Box User**: Can access the developer portal

### Using Azure Portal

1. Navigate to your Project
2. Go to "Access control (IAM)"
3. Click "Add role assignment"
4. Assign appropriate roles to users or groups

### Using Azure CLI

```bash
# Assign user to project
USER_PRINCIPAL_ID="user-object-id"

az role assignment create \
  --assignee $USER_PRINCIPAL_ID \
  --role "Deployment Environments User" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DevCenter/projects/$PROJECT_NAME"
```

## Step 7: Deploy Environment (Developer Workflow)

### Using Developer Portal

1. Navigate to https://devportal.microsoft.com
2. Select your project
3. Click "New environment"
4. Choose "secure-webapp" environment definition
5. Fill in parameters:
   - **Environment Name**: `my-webapp-dev`
   - **Location**: `japaneast`
   - **App Service Plan SKU**: `B1` (for development)
   - **SQL Database SKU**: `Basic` (for development)
6. Click "Create"

### Using Azure CLI

```bash
# Create environment
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

## Step 8: Verify Deployment

After deployment, verify the following resources are created:

1. **Resource Group**: Named with environment prefix
2. **App Services**: Frontend and backend applications
3. **SQL Database**: With private endpoint
4. **Key Vault**: With secrets and proper access policies
5. **Virtual Network**: With proper subnet configuration
6. **Application Gateway**: If enabled

## Troubleshooting

### Common Issues

1. **Catalog Sync Failure**
   - Verify repository URL and branch
   - Check path to catalog directory
   - Ensure manifest.yaml is valid

2. **Permission Errors**
   - Verify user has appropriate roles
   - Check subscription permissions
   - Validate resource group access

3. **Deployment Failures**
   - Review deployment logs in the portal
   - Check parameter values
   - Verify quota limits

### Logs and Monitoring

- **Activity Log**: View deployment activities
- **Deployment History**: Check detailed deployment logs
- **Resource Health**: Monitor resource status

## Best Practices

1. **Environment Naming**: Use consistent naming conventions
2. **Resource Tagging**: Apply tags for cost tracking and governance
3. **Security**: Regularly review access permissions
4. **Cost Management**: Monitor environment costs and set budgets
5. **Lifecycle**: Implement environment cleanup policies

## Next Steps

1. Customize the environment template for your specific needs
2. Add additional environment definitions for different application types
3. Implement CI/CD integration with GitHub Actions
4. Set up monitoring and alerting for deployed environments
5. Create environment management policies and governance

## Resources

- [Azure Deployment Environments Documentation](https://learn.microsoft.com/en-us/azure/deployment-environments/)
- [Bicep Language Reference](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/)
- [Best Practices for ADE Catalogs](https://learn.microsoft.com/en-us/azure/deployment-environments/best-practice-catalog-structure)