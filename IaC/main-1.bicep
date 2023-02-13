// Region for all resources
param location string
param resourceGroupName string = 'rg-myname'

//param location string = resourceGroup().location
param createdBy string = 'yourname'
param costCenter string = '12345678'
param nickName string = 'yourname'

// Variables for Recommended abbreviations for Azure resource types
// https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
// var webAppPlanName = 'appplan-${uniqueString(resourceGroup().id)}'
//var webSiteName = 'app-${uniqueString(resourceGroup().id)}'

// Resource names may contain alpha numeric characters only and must be between 5 and 50 characters.
var containerregistryName = 'cr${uniqueString(resourceGroup().id)}'
var containerName = 'containers-${uniqueString(resourceGroup().id)}'
var containerAppName = 'ca-${uniqueString(resourceGroup().id)}'
var containerAppEnvName = 'cae-${uniqueString(resourceGroup().id)}'
var containerAppLogAnalyticsName = 'calog-${uniqueString(resourceGroup().id)}'

// Default image needed to create Container App
// https://mcr.microsoft.com/en-us/product/mcr/hello-world/about
//var containerImage = 'mcr.microsoft.com/mcr/hello-world:v2.0'
var containerImage = 'nginx:latest' //'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

// Tags
var defaultTags = {
  App: 'appname'
  CostCenter: costCenter
  CreatedBy: createdBy
  NickName: nickName
}

module resourcegroupmod 'main-1-ResourceGroup.bicep' = {
  name: resourceGroupName
  scope: subscription()
  params: {
    defaultTags: defaultTags
    location: location
    resourceGroupName: resourceGroupName
  }
}

// Create Azure Container Registry
 module containerregistrymod './main-1-ContainerRegistry.bicep' = {
  name: containerregistryName
  params: {
    containerregistryName: containerregistryName
    location: location
  }
  dependsOn:  [
    resourcegroupmod
  ]
 }

 // Create Azure Container App
  module containerappmod './main-1-ContainerApps.bicep' = {
   name: containerAppName
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
   dependsOn:  [
    resourcegroupmod
    containerregistrymod
   ]
  }

output out_containerregistryName string = containerregistryName
output out_containerAppName string = containerAppName
output out_containerAppEnvName string = containerAppEnvName
output out_containerName string = containerName
output out_containerAppFQDN string = containerappmod.outputs.containerAppFQDN
