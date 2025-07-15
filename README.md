# Azure Deployment Environments Catalog Repository

This repository manages the catalog for Azure Deployment Environments (ADE).

- It provides infrastructure templates and configuration for deploying environments using ADE.
- For detailed usage, setup, and deployment instructions for the WebApp-ACR-templates, see [README_ADE.md](./environments/WebApp-ACR-templates/README_ADE.md).

---

## Prerequisites
- Azure Deployment Environments (Dev Center/Project) must be already set up in your Azure subscription.
- Finish these steps:
  - [Quickstart: Configure Azure Deployment Environments](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-create-and-configure-devcenter)
  - [Quickstart: Create dev center and project for Azure Deployment Environments by using an ARM template](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-create-dev-center-project-azure-resource-manager)
  - [Quickstart: Create and access an environment in Azure Deployment Environments](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-create-access-environments?tabs=no-existing-environments)
- *This repository should be registered as a catalog in your Dev Center or Project.

---

## Useful Microsoft Docs
- [Azure Deployment Environments Overview](https://learn.microsoft.com/en-us/azure/deployment-environments/overview)
- [How to set up Dev Center and Projects](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-project-setup)
- [Catalog Best Practices](https://learn.microsoft.com/en-us/azure/deployment-environments/best-practice-catalog-structure)

---

## DevSecOps and Security

This repository implements DevSecOps best practices for Infrastructure as Code (IaC):

- **[IaC DevSecOps Architecture](./iac-devsecops-architecture.md)** - Comprehensive DevSecOps implementation guide
- **[Security Checklist](./security-checklist.md)** - Security validation checklist for main.bicep
- **Automated Security Scanning** - PSRule, Checkov, and secret detection in CI/CD
- **Policy as Code** - Azure Policy integration for compliance
- **Security Baseline** - CIS Azure Foundations Benchmark compliance

---

For all details about the WebApp-ACR-templates catalog and deployment, please see [README_ADE.md](./environments/WebApp-ACR-templates/README_ADE.md).
