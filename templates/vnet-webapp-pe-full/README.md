# azure-bicep-templates
A collection of Bicep templates


## PaaS solution with Private Endpoints

### Diagram


![Diagram](/templates/pe-full/pe-full.png)


### Infrastructure-as-code (Bicep)

The template creates:

- VNET and the following subnets:
  - Default
  - AzureBastionSubnet
  - vmSubnet
  - peSubnet
  - webappBESubnet
  - funcappBESubnet
  - laappBESubnet
- Links the private DNS zones to VNET
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

### Test Code

#### Azure Functions

#### Logic App

#### WebApp