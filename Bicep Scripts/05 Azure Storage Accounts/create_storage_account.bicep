// Objective: Create storage account only. This will be an empty storage account.

// Requirements
// - `Microsoft.Storage`
//   - `storageAccounts` module
//       1. name : name of the storage account.
//       2. location: resource group.
//       3. sku.name: name of the plan subscribed for the storage account
//           1. `Standard_LRS`
//       4. kind: kind of storage account
//           1. `StorageV2`

param location string = resourceGroup().location
param SA_SKU string

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'demotestrg1'
  location: location
  sku: {
    name: SA_SKU
  }
  kind: 'StorageV2'
}
