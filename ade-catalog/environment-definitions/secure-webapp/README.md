# Secure Web Application Environment

This Azure Deployment Environments definition creates a complete, secure, and scalable web application infrastructure following Azure best practices.

## Architecture

The template deploys the following components:

### Core Infrastructure
- **Virtual Network**: Segmented subnets for App Services, Application Gateway, and Private Endpoints
- **App Service Plan**: Linux-based plan supporting containerized applications
- **Frontend App Service**: Container-based frontend application
- **Backend App Service**: Container-based backend API
- **Azure SQL Database**: Managed database with private endpoint connectivity
- **Azure Key Vault**: Centralized secrets management with RBAC
- **Application Insights**: Application performance monitoring
- **Log Analytics Workspace**: Centralized logging and monitoring

### Security Features
- **Managed Identity**: Passwordless authentication for all services
- **Private Endpoints**: Private connectivity for SQL Database and Key Vault
- **VNet Integration**: App Services integrated with virtual network
- **Application Gateway**: Web Application Firewall (WAF) protection
- **RBAC**: Role-based access control for Key Vault access
- **HTTPS Only**: All web traffic enforced over HTTPS

### Network Security
- Dedicated subnets for different service tiers
- Private DNS zones for private endpoint resolution
- Network security groups (implied through subnet delegation)
- Public access disabled for SQL Database and Key Vault

## Parameters

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `environmentName` | Name prefix for all resources | - | Yes |
| `location` | Azure region for deployment | japaneast | Yes |
| `appServicePlanSku` | App Service Plan pricing tier | P1v3 | No |
| `sqlDatabaseSku` | SQL Database pricing tier | S1 | No |
| `enableApplicationGateway` | Deploy Application Gateway with WAF | true | No |
| `containerImageTag` | Container image tag for applications | latest | No |

## Deployment

This environment is designed to be deployed through Azure Deployment Environments (ADE). The following steps are required:

1. Register this catalog in your Dev Center
2. Create an environment definition pointing to this template
3. Deploy through the Developer Portal or Azure CLI

### Prerequisites

- Azure subscription with appropriate permissions
- Dev Center configured with this catalog
- Container images available in a container registry (for actual applications)

## Post-Deployment Configuration

After deployment, the following manual steps may be required:

1. **Container Images**: Update App Services with actual container images
2. **SSL Certificates**: Configure SSL certificates for Application Gateway
3. **Database Schema**: Initialize database schema and data
4. **Application Configuration**: Update application settings and connection strings
5. **DNS Configuration**: Point custom domains to Application Gateway

## Monitoring

The environment includes comprehensive monitoring:

- **Application Insights**: Application performance and user analytics
- **Log Analytics**: Centralized logging for all Azure resources
- **Azure Monitor**: Infrastructure metrics and alerting

## Security Best Practices Implemented

- Managed Identity for passwordless authentication
- Private endpoints for database and key vault connectivity
- VNet integration for App Services
- Web Application Firewall for external traffic protection
- RBAC for fine-grained access control
- Secrets stored in Key Vault with proper access policies
- HTTPS enforced for all web traffic
- Public access disabled for sensitive resources

## Scaling and High Availability

- App Service Plan supports auto-scaling
- SQL Database with built-in high availability
- Application Gateway provides load balancing
- Multi-zone deployment capability (depending on region)

## Cost Optimization

- Configurable SKUs for different environments (dev/test/prod)
- Shared App Service Plan for frontend and backend
- Efficient resource sizing based on workload requirements

## Customization

This template can be customized by:

- Modifying SKUs for different performance requirements
- Adding additional App Services for microservices architecture
- Integrating with Azure Container Registry for CI/CD
- Adding Azure CDN for global content delivery
- Implementing Azure API Management for API governance

## Support

For issues and questions regarding this environment definition, please refer to the repository documentation or contact your platform team.