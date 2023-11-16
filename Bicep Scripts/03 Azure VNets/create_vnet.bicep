// Objective: Create a new vnet of 10.10.0.0/16 and a subnet of 10.10.10.0/24

// `Microsoft.Network`
//   - `virtualNetworks`
//     1. name
//     2. properties.addressSpace.addressPrefixes = ['10.10.0.0/16']
//     3. subnets[]
//        - name
//        - properties.addressSpace.addressPrefixes = ['10.10.0.0/16']

targetScope='resourceGroup'

param location string = resourceGroup().location

param VNet_Name string
param Subnet_Name string

resource newVnet2 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: VNet_Name
  location: location
  properties:{
    addressSpace: {
      addressPrefixes:['10.10.0.0/16']
    }
    subnets:[
      {
        name: Subnet_Name
        properties:{
            addressPrefixes:['10.10.10.0/24']
        }
      }
    ]
  }
  
}

// Command:
// az deployment group create -g new-rg2 --template-file './Bicep Scripts/03 Azure VNets/create_vnet.bicep' --parameters VNet_Name=test1-vnet Subnet_Name=otherPrimaryNetwork
