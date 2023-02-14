// Example deploy from CLI
// az deployment sub create --name MyDeploymentName --location eastus2 --template-file ./main.bicep --parameters location=eastus2
//
// Reference
// https://learn.microsoft.com/en-us/cli/azure/deployment/sub?view=azure-cli-latest#az-deployment-sub-create

@description('Location for all resources.')
param location string

@description('Base name that will appear for all resources.') 
param baseName string = 'rpagels'

@description('Three letter environment abreviation to denote environment that will appear in all resource names') 
param environmentName string = 'dev'

param resourceGroupName string = toLower('rg-${baseName}-${environmentName}-${location}')

// Resource names may contain alpha numeric characters only and must be between 5 and 50 characters.
param storageAccountName string = 'sta${uniqueString(resourceGroupName)}'
param containerregistryName string = 'cr${uniqueString(resourceGroupName)}'
param containerName string = 'containers-${uniqueString(resourceGroupName)}'
param containerAppName string = 'ca-${uniqueString(resourceGroupName)}'
param containerAppEnvName string = 'cae-${uniqueString(resourceGroupName)}'
param containerAppLogAnalyticsName string = 'calog-${uniqueString(resourceGroupName)}'

// Deployment at subscription scope.
targetScope = 'subscription'

param tag_appname string = 'appname'
param tag_createdBy string = 'yourname'
param tag_costCenter string = '12345678'
param tag_nickName string = 'yourname'

// Create unique RG name
//param guidValue string = newGuid()
//param resourceGroupName string = toLower('rg-${baseName}-${environmentName}-${location}')

//var resourceGroupName = toLower('rg-${baseName}-${environmentName}-${location}')

// // Resource names may contain alpha numeric characters only and must be between 5 and 50 characters.
// param storageAccountName string = 'sta${uniqueString(resourceGroupName)}'

// //var storageAccountName = 'sta${uniqueString(resourceGroupName)}'
// var containerregistryName = 'cr${uniqueString(resourceGroupName)}'
// var containerName = 'containers-${uniqueString(resourceGroupName)}'
// var containerAppName = 'ca-${uniqueString(resourceGroupName)}'
// var containerAppEnvName = 'cae-${uniqueString(resourceGroupName)}'
// var containerAppLogAnalyticsName = 'calog-${uniqueString(resourceGroupName)}'

// Default image needed to create Container App
// https://mcr.microsoft.com/en-us/product/mcr/hello-world/about
var containerImage = 'nginx:latest' //'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

// Tags
var defaultTags = {
  App: tag_appname
  CostCenter: tag_costCenter
  CreatedBy: tag_createdBy
  NickName: tag_nickName
}

// Since we are mismatching scopes with a deployment at subscription and resource at resource group
// the main.bicep requires a Resource Group deployed at the subscription scope, all modules will be at the Resourece Group scope

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  name: resourceGroupName
  location: location
  tags:{
    environment: environmentName
  }
}

module storageAccount './main-StorageAccount.bicep' ={
  name: 'storageAccountModule'
  scope: resourceGroup  // Deployment at resource group scope.
  params:{
    location: location
    storageAccountName: storageAccountName //nameSuffix
    defaultTags: defaultTags
  }
}

// Create Azure Container Registry
module containerregistrymod './main-ContainerRegistry.bicep' = {
  name: 'containersModule'
  scope: resourceGroup  // Deployment at resource group scope.
  params: {
    containerregistryName: containerregistryName
    location: location
  }
}

 // Create Azure Container App
 module containerappmod './main-ContainerApps.bicep' = {
  name: containerName
  scope: resourceGroup  // Deployment at resource group scope.
  params: {
    containerAppEnvName: containerAppEnvName
    containerAppLogAnalyticsName: containerAppLogAnalyticsName
    containerAppName: containerAppName
    location: location
    containerregistryName: containerregistryName
    containerregistryNameLoginServer: containerregistrymod.outputs.acrLoginServer
    containerregistryNameCredentials: containerregistrymod.outputs.output_acr_pass
    containerImage: containerImage
    defaultTags: defaultTags
  }
 }
