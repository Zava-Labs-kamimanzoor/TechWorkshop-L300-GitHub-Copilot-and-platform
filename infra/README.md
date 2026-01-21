# ZavaStorefront Infrastructure (Dev Environment)

This folder contains Bicep modules and instructions to provision all Azure resources for the ZavaStorefront web application development environment as described in issue 1.

## Resources Provisioned
- Resource Group (westus3)
- Azure Container Registry (ACR)
- Linux App Service (WebApp) with RBAC for ACR
- Application Insights
- Microsoft Foundry (GPT-4, Phi)

## Deployment Instructions

### Prerequisites
- [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
- [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
- Azure subscription with access to westus3

### Steps
1. **Clone the repository**
2. **Login to Azure**
   ```sh
   az login
   ```
3. **Initialize AZD project**
   ```sh
   azd init
   ```
4. **Provision infrastructure**
   ```sh
   azd up
   ```

### Notes
- All resources are deployed in a single resource group in `westus3`.
- App Service is configured to pull images from ACR using managed identity (RBAC).
- Application Insights and Foundry endpoints are injected as app settings.
- Update `<your-acr-image>` in `appservice.bicep` with your actual ACR image name.

## Onboarding
- Share these instructions with your team for easy onboarding.
- For more details, see the official docs:
  - [AZD Documentation](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)
  - [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
