# Azure Deployment Environments Catalog: WebApp with ACR

This repository provides a reusable Azure Deployment Environments (ADE) catalog for deploying a secure and scalable web application environment. It uses modular Bicep templates and supports OIDC-based GitHub Actions CI/CD.

---

## 1. Overview
- Deploys: Azure App Service (frontend/backend), Azure SQL Database, Azure Key Vault, Azure Container Registry (ACR), Application Insights, VNet, and more
- Security: Managed Identity, Private Endpoints, Key Vault integration
- see [webapp-acr-architecture.md](/webapp-acr-architecture.md) for detailed architecture
- Ready for: sync 'environment' folder path with Azure Deployment Environment (ADE) and bicep validation with GitHub Actions CI/CD

---

## 2. Prerequisites
- Azure subscription
- Azure CLI installed (`az login`)
- Azure Deployment Environments (Dev Center/Project) set up
- This catalog repository registered in your Dev Center or Project
- Contributor or Owner permissions on your Azure subscription

---

## 3. Catalog Structure

```
/environments/WebApp-ACR-templates/
  ├─ main.bicep
  ├─ network.bicep
  ├─ keyvault.bicep
  ├─ sql.bicep
  ├─ appInsights.bicep
  ├─ appService.bicep
  └─ environment.yaml
/scripts/
  └─ setup-oidc-github-sp.sh
```

- `environment.yaml`: ADE catalog manifest (environment definition)
- `main.bicep`: Main entry point for deployment
- Other Bicep files: Resource modules
- `scripts/setup-oidc-github-sp.sh`: OIDC Service Principal setup script for GitHub Actions

---

## 4. How to Configure and Deploy (Step by Step)

## [For Plaform Engineer] How to Syc this Catalog to ADE
1. Go to ADE > Developer center > Environment Configuration
2. Click Add and set the path to this catalog repository (e.g. `environments/WebApp-ACR-templates`)

## [For Developer] How to Create Environment (Step by Step)
1. Go to [Developer portal](https://devportal.microsoft.com/)
2. Click "Create new environment" and select `WebApp-with-ACR Environment`
3. Enter required parameters (e.g. `envName`, `sqlAdminPassword`)
4. Click Create

---

## 5. Parameters
| Name             | Required | Description                                      |
|------------------|----------|--------------------------------------------------|
| envName          | Yes      | Name prefix for resources in this environment    |
| sqlAdminPassword | Yes      | SQL Server admin password (plain string)         |

---

## 6. OIDC Service Principal Setup for GitHub Actions

To enable OIDC authentication for GitHub Actions, follow these steps:

### Prerequisites
- Azure CLI installed and logged in (`az login`)
- Contributor or Owner permissions on your Azure Subscription
- The following variables ready:
  - Azure Subscription ID
  - Azure Tenant ID
  - GitHub repository owner (username or org)
  - GitHub repository name
  - Service Principal name (e.g. `sp-ade-webapp-acr`)

### Step-by-step Guide

1. **Set environment variables**
   ```bash
   export SUBSCRIPTION_ID="<your-subscription-id>"
   export TENANT_ID="<your-tenant-id>"
   export GITHUB_ORG="<your-github-username-or-org>"
   export GITHUB_REPO="<your-repo-name>"
   export SP_NAME="sp-ade-webapp-acr"
   ```
2. **Run the setup script**
   ```bash
   bash scripts/setup-oidc-github-sp.sh
   ```
   Or, pass arguments directly:
   ```bash
   bash scripts/setup-oidc-github-sp.sh <SUBSCRIPTION_ID> <TENANT_ID> <GITHUB_ORG> <GITHUB_REPO> <SP_NAME>
   ```
3. **Register output values as GitHub Secrets**
   - After the script runs, it will output:
     - `AZURE_CLIENT_ID`
     - `AZURE_TENANT_ID`
     - `AZURE_SUBSCRIPTION_ID`
   - Go to your GitHub repository > Settings > Secrets and variables > Actions, and add these as new secrets.
4. **Use OIDC authentication in your GitHub Actions workflow**
   ```yaml
   - name: Azure Login (OIDC)
     uses: azure/login@v1
     with:
       client-id: ${{ secrets.AZURE_CLIENT_ID }}
       tenant-id: ${{ secrets.AZURE_TENANT_ID }}
       subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
       enable-AzPSSession: true
   ```

---

## 7. Best Practices & Notes
- All resources are deployed to Japan East (`japaneast`). Change the location in `main.bicep` if needed.
- App Service plan uses Standard (S1) SKU
- No deployment slots are created by default
- Key Vault name must be globally unique and 3-24 alphanumeric characters
- SQL admin password is handled as a plain string due to ADE limitations
- Review and adjust Bicep modules and parameters as needed for your use case

---

## 8. References
- [Azure Deployment Environments Documentation](https://learn.microsoft.com/en-us/azure/deployment-environments/)
- [Catalog Best Practices](https://learn.microsoft.com/en-us/azure/deployment-environments/best-practice-catalog-structure)
- [Bicep Best Practices](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)

---

## 9. How Resource Validity is Ensured

The validity of Azure resources created by `main.bicep` is automatically checked by the CI workflow (`webapp-acr-bicep-ci.yml`).
- On every pull request, GitHub Actions runs:
  - **Bicep lint**: Checks Bicep syntax and best practices
  - **What-if deployment**: Simulates the deployment to verify resource creation and parameter validity without making changes
- This ensures that any changes to the Bicep templates are validated before merging, reducing the risk of deployment errors.

**Security Recommendation:**
- It is strongly recommended to enable GitHub Advanced Security features for this repository:
  - **Code scanning**: Detects vulnerabilities and security issues in your code and templates
  - **Secret scanning**: Detects accidental exposure of secrets (passwords, keys, etc.) in your repository
- These features help keep your infrastructure code secure and compliant.
