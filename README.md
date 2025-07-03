# azure-ade-platform-templates

This repository provides reusable infrastructure templates designed for [Azure Deployment Environments (ADE)](https://learn.microsoft.com/en-us/azure/deployment-environments/overview).  
These templates enable secure, scalable, and developer-friendly application environments that can be deployed via the Azure Dev Portal.

## ✅ Features

- 🧱 Modular Bicep templates
- 🔐 Secure-by-default configuration
  - Managed Identity, Private Endpoints, Key Vault integration
- 🖥️ Application stack:
  - Azure App Service (Frontend & Backend, container-based)
  - Azure SQL Database
  - Azure Container Registry (ACR)
  - Azure Key Vault
  - Application Gateway with WAF
  - Application Insights
- 📦 Ready to use in ADE Dev Portal with environment.yaml

## 📁 Template Structure

```bash
/
├── environment.yaml        # ADE catalog definition
├── main.bicep             # Entry point Bicep template
├── network.bicep
├── keyvault.bicep
├── sql.bicep
├── appInsights.bicep
├── appService.bicep
├── gateway.bicep (optional)
└── parameters/
    ├── dev.bicepparam
    └── prod.bicepparam
