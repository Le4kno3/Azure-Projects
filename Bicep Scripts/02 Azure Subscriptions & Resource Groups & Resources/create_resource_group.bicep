// Objective: Create a new resource group. This script needs to be run at subscription level as logically resource group level is lower than subscription level.

// Ref: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/create-resource-group

targetScope='subscription'

param RG_name string
param RG_location string

resource newRGCreate 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: RG_name
  location: RG_location
}

// Command:
// az deployment sub create --location EastUS --template-file './Bicep Scripts/02 Azure Subscriptions & Resource Groups/create_resource_group.bicep' --parameters RG_name=new-rg2 RG_location=eastus
