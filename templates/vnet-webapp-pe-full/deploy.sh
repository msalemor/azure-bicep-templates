# Variables

version=8
domain=contoso
project=pj
env=poc
location=eastus
shortloc=eus
rg_name="rg-${domain}${project}${version}-${env}-${shortloc}"
#echo $version $rg_name

# Deployment

az group delete -y -g $rg_name

az group create -g $rg_name -l $location

az deployment group create -g $rg_name -p version=$version -p domain=$domain -p project=$project -p env=$env --template-file main.bicep -n deployment1
