#!/bin/bash

# Quickstart: Deploy your code to Azure Container Apps - Cloud build
# https://learn.microsoft.com/en-us/azure/container-apps/quickstart-code-to-cloud?tabs=bash%2Ccsharp&pivots=acr-remote


#az login
#az account set --subscription $SUBSCRIPTIONID
#az upgrade

: << 'COMMENT'
This is the first line of a multiline comment
This is the second line
COMMENT

# Next, install or update the Azure Container Apps extension for the CLI.
#az extension add --name containerapp --upgrade

# Register the Microsoft.App and Microsoft.OperationalInsights namespaces if you 
# haven't already registered them in your Azure subscription.
#az provider register --namespace Microsoft.App
#az provider register --namespace Microsoft.OperationalInsights

#setup environment variables
RESOURCE_GROUP="rg-containerapp"
LOCATION="westus"
ENVIRONMENT="env-album-containerapps"
API_NAME="album-api"
FRONTEND_NAME="album-ui"
GITHUB_USERNAME="bgfast"
CUSERNAME="crbrent"
# Define a container registry name unique to you.
ACR_NAME="crbrent"


# create the container registry
#az acr create \
#  --resource-group $RESOURCE_GROUP \
#  --name $ACR_NAME \
#  --sku Basic \
#  --admin-enabled true

: << 'COMMENT'
# Build the container in Azure
az acr build --registry $ACR_NAME --image $API_NAME .

# Create the container app environment
az containerapp env create \
  --name $ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --logs-destination none \
  --location "$LOCATION"
COMMENT

# Create the container app and deploy the image
az containerapp create \
  --name $API_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image $ACR_NAME.azurecr.io/$API_NAME \
  --target-port 3500 \
  --ingress 'external' \
  --registry-server $ACR_NAME.azurecr.io \
  --query properties.configuration.ingress.fqdn \
  --registry-password $CPASSWORD \
  --registry-username $CUSERNAME

#docker login crbrent.azurecr.io

# https://album-api.mangowave-d948cf28.westus.azurecontainerapps.io/albums


