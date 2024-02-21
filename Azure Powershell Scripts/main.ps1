
# Give the names of the resources.
# Location is eastus for all
$rgName='newRg'
$location='eastus'
$vnet1ARG = @{
  "name" = "vnet1"  #Note you can always change the name later after the script is executed.
  "addressPrefix" = "10.10.0.0/16"
  "subnet1" = @{
    "name" = "subnet1"
    "addressPrefix" = "10.10.10.0/24"
  }
  "subnet2" = @{
    "name" = "subnet2"
    "addressPrefix" = "10.10.11.0/24"
  }
}

# For network service tags: https://learn.microsoft.com/en-us/azure/virtual-network/service-tags-overview
# NSG allows all outgoing traffic
# NSG to deny all incomming traffic except 80, 443
$nsg1ARG = @{
  "name" = "AllowIncomming80And443"
  "rule1" = @{
    "direction" = "inbound"
    "priority" = "100"
    "access" = "allow"
    "sourceAddressPrefix" = "VirtualNetwork"
    "sourcePort" = "*"
    "destinationAddressPrefix" = "Storage"
    "destinationPort" = "80,443"
    "protocol" = "tcp"
  }
  "rule2" = @{
    "direction" = "inbound"
    "priority" = "110"
    "access" = "deny"
    "sourceIP" = "*"
    "sourcePort" = "*"
    "destinationIP" = "*"
    "destinationPort" = "*"
    "protocol" = "tcp"
  }
}

# For Windows: az vm image list --all --publisher MicrosoftWindowsDesktop --offer 11
# For Linux: az vm image list --all --publisher canonical --offer server --sku lts
$vmCount=2
$vmNICs = @{  #IPs are dynamically assigned for not making this complex
  "count" = $vmCount
  "resourceGroupName" = $rg.ResourceGroupName
  "location" = $rg.Location
  "nic1" = @{
    "name" = "nic1"
    "vnetName" = $vnet1ARG.name
    "subnetName" = $vnet1ARG.subnet1.name
    "ipConfigName" = "nic1IpConfig"
    "nsgName" = $nsg1ARG.name 
  }
  "nic2" = @{
    "name" = "nic2"
    "vnetName" = $vnet1ARG.name
    "subnetName" = $vnet1ARG.subnet2.name
    "ipConfigName" = "nic2IpConfig"
    "nsgName" = $nsg1ARG.name
  }
}
$vm1ARG = @{
  "name" = "VirtualMachine1"  #Note you can always change the name later after the script is executed.
  "image" = "win11-23h2-pro"
  "username" = "windows"
  "nsg" = $nsg1ARG
}

#######################   RESOURCE GROUP     #####################
  # New ResourceGroup
  $rg=New-AzResourceGroup `
    -Location $location `
    -Name $rgName

######################   VIRTUAL NETWORKS    ######################
  # Create a new virtual network
  $vnet1=New-AzVirtualNetwork `
    -ResourceGroupName $rg.ResourceGroupName `
    -AddressPrefix $vnet1ARG.addressPrefix`
    -Location $rg.Location `
    -Name $vnet1ARG.name

  # Get the default subnet: The default subnet is not created by default, it is just an ease thing in GUI.
  # $vnetSubnet1=Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name default

  # Create 1st subnet config
  $vnet1Subent1=Add-AzVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet1 `
    -AddressPrefix $vnet1ARG.subnet1.addressPrefix `
    -Name $vnet1ARG.subnet1.name

  # Create 2nd subnet config
  $vnet1Subent2=Add-AzVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet1 `
    -AddressPrefix $vnet1ARG.subnet2.addressPrefix `
    -Name $vnet1ARG.subnet2.name

  # Push the local vnet subnet config to Azure
  Set-AzVirtualNetwork -VirtualNetwork $vnet1

################   NETWORK SECURITY GROUPS   ####################
  # Create a new NSG resource
  $nsg1=New-AzNetworkSecurityGroup `
    -Name $nsg1ARG.name `
    -ResourceGroupName $vnet1.ResourceGroupName `
    -Location $vnet1.Location

  # Create rule 1
  Add-AzNetworkSecurityRuleConfig `
    -Name $nsg1ARG.rule1.name `
    -NetworkSecurityGroup $nsg1 `
    -Protocol $nsg1ARG.rule1.protocol `
    -SourceAddressPrefix $nsg1ARG.rule1.sourceAddressPrefix `
    -SourcePortRange $nsg1ARG.rule1.sourcePort `
    -DestinationAddressPrefix $nsg1ARG.rule1.destinationAddressPrefix `
    -DestinationPortRange $nsg1ARG.rule1.destinationPort `
    -Access $nsg1ARG.rule1.access `
    -Priority $nsg1ARG.rule1.priority `
    -Direction $nsg1ARG.rule1.direction

  # Create rule 2
  Add-AzNetworkSecurityRuleConfig `
    -Name $nsg1ARG.rule2.name `
    -NetworkSecurityGroup $nsg1 `
    -Protocol $nsg1ARG.rule2.protocol `
    -SourceAddressPrefix $nsg1ARG.rule2.sourceAddressPrefix `
    -SourcePortRange $nsg1ARG.rule2.sourcePort `
    -DestinationAddressPrefix $nsg1ARG.rule2.destinationAddressPrefix `
    -DestinationPortRange $nsg1ARG.rule2.destinationPort `
    -Access $nsg1ARG.rule2.access `
    -Priority $nsg1ARG.rule2.priority `
    -Direction $nsg1ARG.rule2.direction

######################   VIRTUAL MACHINES   ########################
  # Create all the NICs for the required virtual machines
  For ($i=1; $i -le $vmNICs.count; $i++) {
    $tmpVnet=Get-AzVirtualNetwork -Name `$vmNICs.nic$i.vnetName`
    $tmpSubnet=Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet1 -Name `subnet$i`
    New-AzNetworkInterface `
      -ResourceGroupName $vmNICs.resourceGroupName `
      -VirtualNetwork `$vmNICs.nic$i.vnetName` `
      -Location $tmpVnet.Location `
      -SubnetId $tmpSubnet.Id `
      -IpConfigurationName `$vmNICs.nic$i.ipConfigName`
      -Name `$vmNICs.nic$i.name`
  }

  # Create the VM using the NICs
  

