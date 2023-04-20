RG_PROJECT=havas7
DEPLOYMENT_NAME=deployment$RG_PROJECT

# Scope: subscription
# Deployment to a resource group
az deployment sub create \
  --name $DEPLOYMENT_NAME \
  --location eastus \
  --template-file main.bicep \
  --parameters rgName=rg-$RG_PROJECT-poc-eus location=eastus project=$RG_PROJECT adminPassword=Fuerte#123456789 \
  --what-if

##--nowait