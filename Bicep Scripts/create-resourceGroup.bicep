// this is a standard value "resourceGroup().location" that provides flexibility while creating resrouces.
// - name
// - resource group
// - sku : Standard_LRS
// - kind : StorageV2

param location string = resourceGroup().location

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'demotestrg1'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
