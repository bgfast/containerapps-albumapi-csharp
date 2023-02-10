param location string
param resourceGroupName string
param defaultTags object

// Create Azure Resource Group
targetScope = 'subscription'
resource resourcegroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: defaultTags
}
