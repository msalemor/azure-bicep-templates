<div id="top"></div>
<div align="center">

  <h3 align="center">Private Endpoints full</h3>

  <p align="center">
    Secure enterprise with Private endpoints
    <br />
    <a href="https://docs.microsoft.com/EN-US/azure/azure-resource-manager/bicep/"><strong>Explore Bicep docs »</strong></a>
    <br />
    <br />
  </p>
</div>

----------
<details open>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#overview">Overview</a></li>
    <li><a href="#reference-diagram">Reference Diagram</a></li>
    <li><a href="#resources">Resources</a></li>
    <li><a href="#try-it-out">Try it out</a></li>
    <li><a href="#deploying-web-app-using-github-actions">Deploying Web App using GitHub Actions</a></li>
    <li><a href="#extra-learning-resources">Extra learning resources</a></li>
  </ol>
</details>

## Overview
This template will create an enterprise-like environment with Azure PaaS services, including underlying connectivity with VNets, everything secured with Private Endpoints.

## Reference diagram
The following diagram showcases the environment created by this template.
![Reference diagram](/images/pe-full.png)

## Resources
Once you deploy this template it will create for you:

- VNet and the following subnets:
  - Default
  - AzureBastionSubnet
  - vmSubnet
  - peSubnet
  - webappBESubnet
  - funcappBESubnet
  - laappBESubnet
- Links the private DNS zones to VNet
- Public IP and Bastion
- dev VM
- SQL Server and database under Private Endpoint
- Web App with managed identity
- Function App with managed identity
- Logic App with managed identity
- Key Vault
- App Configuration with managed identity
- Secrets
- Key Vault access policies for the managed identities

For the Web App, Function App, and Logic App:

- Create storage account under with Private Endpoints for
  - blob, file, table and queues
  - Added the URI in the App Settings
- Create an Application Insights instance

## Try it out
You can try this template on your subscription by running [deploy1.sh](deploy1.sh) using Azure CLI. You can update the variables to change the Azure region location, project name, and more.

## Deploying Web App using GitHub Actions
[azure-webapps-dotnet-core.yml](/.github\workflows\azure-webapps-dotnet-core.yml) workflow will build and push a .NET Core app `templates\pe-full\src\webapp` to an Azure Web App when a commit is pushed to your default branch.
It assumes you have already created the target Azure App Service web app.
For instructions refer to [this docs ](https://docs.microsoft.com/en-us/azure/app-service/quickstart-dotnetcore?tabs=net60&pivots=development-environment-vscode).

To configure this workflow:
* Download the Publish Profile for your Azure Web App. You can download this file from the Overview page of your Web App in the Azure Portal. Instructions [here](https://docs.microsoft.com/en-us/azure/app-service/deploy-github-actions?tabs=applevel#generate-deployment-credentials).
* Create a secret in your repository named `AZURE_WEBAPP_PUBLISH_PROFILE`, paste the publish profile contents as the value of the secret.
For instructions on configuring github secrets check [here](https://docs.microsoft.com/azure/app-service/deploy-github-actions#configure-the-github-secret).
* Change the value for the `AZURE_WEBAPP_NAME`. Optionally, change the AZURE_WEBAPP_PACKAGE_PATH and DOTNET_VERSION environment variables from [azure-webapps-dotnet-core.yml](/.github/workflows/azure-webapps-dotnet-core.yml)

### Extra learning resources:

* [GitHub Actions for Azure](https://github.com/Azure/Actions)
* [Azure Web Apps Deploy action](https://github.com/Azure/webapps-deploy)
* [GitHub Action workflows to deploy to Azure](https://github.com/Azure/actions-workflow-samples)

<p align="right">(<a href="#top">back to top</a>)</p>