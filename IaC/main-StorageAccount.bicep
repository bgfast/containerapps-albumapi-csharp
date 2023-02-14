// =========== storage.bicep ===========
param location string
param storageAccountName string
param defaultTags object

// targetScope = 'resourceGroup' - not needed since it is the default value

resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  tags: defaultTags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
