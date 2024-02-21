// Objective: Create a resource lock on a virtual network, the resource name of this virtual network will be provided in runtime.

targetScope='resourceGroup'

@description('The name of the resource lock.')
param Lock_Name string

@description('The lock type of the resource lock.')
param Lock_Type string

@description('The vnet name where this resource lock needs to be created.')
param Vnet_Name string

//create config map to make it easy for user inputs.
var lockList = {
  delete: 'CanNotDelete'
  readonly: 'ReadOnly'
}

resource vnetSelected 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: Vnet_Name
}

// this creates a delete resource lock
// we can further improvise this script by taking a simpler value as parameter and then processing it to obtain the actual value that is needed.
resource newRSLock 'Microsoft.Authorization/locks@2020-05-01' = {
  name: Lock_Name
  scope: vnetSelected
  properties: {
    level: lockList[Lock_Type]
  }
}

// command:
// az deployment group create -g new-rg2 --template-file .\create_resource_lock.bicep --parameters Lock_Name=pleasedontdelete Lock_Type=delete Vnet_Name=test2-vnet
