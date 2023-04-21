RG_PROJECT=havas
VERSION=4
DEPLOYMENT_NAME=deployment$RG_PROJECT$VERSION

# Scope: subscription
# Deployment to a resource group
az deployment sub create \
  --name $DEPLOYMENT_NAME \
  --location eastus \
  --template-file main.bicep \
  --parameters project=$RG_PROJECT version=$VERSION location=eastus adminPassword=Fuerte#123456789 \
  --no-wait
##  --what-if
#--nowait
#  --what-if
##--nowait