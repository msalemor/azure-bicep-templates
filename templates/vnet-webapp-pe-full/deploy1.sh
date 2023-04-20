# Variables

version=3
domain=contoso
project=pj
env=poc
location=eastus
shortloc=eus
rg_name="rg-${domain}${project}${version}-${env}-${shortloc}"
deployFrontPE=true

# Deployment - Updating

az deployment group create -g $rg_name -p version=$version -p domain=$domain -p project=$project -p env=$env -p deployFrontPE=$deployFrontPE --template-file main.bicep -n deployment2