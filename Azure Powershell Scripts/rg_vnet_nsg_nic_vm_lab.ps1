
# Summary of the actions
# Note: All resources will be created in this resource group with the same location of the resource group.
# 1. Create a new resource group
# 2. Create 1 vnet and then create 2 subnets inside this vnet.
# 3. Create 2 NICs and associate it with 2 subnets.
# 4. Create 1 NSG and apply the nsg to the 2 subents.
# 5. Create 2 VMs and NIC associated with it.


# All the parameters need to be defined here, you dont need to customize anything later.
# The parameter "location" is default value it will be udpated based on the name of the rg at point when the resource group is created. 
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
  "name" = "AllowIncomming80And443ThenDenyAll"
  "rule1" = @{
    "name" = "AllowIncomming80And443"
    "direction" = "inbound"
    "priority" = "100"
    "access" = "allow"
    "sourceAddressPrefix" = "VirtualNetwork"
    "sourcePort" = "*"
    "destinationAddressPrefix" = "Storage"
    "destinationPort" = 80,443
    "protocol" = "tcp"
  }
  "rule2" = @{
    "name" = "DenyAll"
    "direction" = "inbound"
    "priority" = "110"
    "access" = "deny"
    "sourceAddressPrefix" = "*"
    "sourcePort" = "*"
    "destinationAddressPrefix" = "*"
    "destinationPort" = "*"
    "protocol" = "tcp"
  }
}

# For Windows: az vm image list --all --publisher MicrosoftWindowsDesktop --offer 11
# For Linux: az vm image list --all --publisher canonical --offer server --sku lts
$vmNICs = @{  #IPs are dynamically assigned for not making this complex
  "count" = 2
  "resourceGroupName" = $rgName
  "location" = $location
  "vnetName" = $vnet1ARG.name
  "nic1" = @{
    "name" = "nic1"
    "subnetName" = $vnet1ARG.subnet1.name
    "ipConfigName" = "nic1IpConfig"
    "nsgName" = $nsg1ARG.name 
  }
  "nic2" = @{
    "name" = "nic2"
    "subnetName" = $vnet1ARG.subnet2.name
    "ipConfigName" = "nic2IpConfig"
    "nsgName" = $nsg1ARG.name
  }
}

$vmARG = @{
  "count" = 2
  "vm1" = @{
    "name" = "VirtualMachine1"  #Note you can always change the name later after the script is executed.
    "PublisherName" = "MicrosoftWindowsDesktop"
    "Offer" = "Windows-11"
    "Skus" = "win11-23h2-pro"
    "Version" = "latest"
    "size" = "Standard_B2s"
    "username" = "windows"
    "nsgName" = $nsg1ARG.name
  }
  "vm2" = @{
    "name" = "VirtualMachine2"  #Note you can always change the name later after the script is executed.
    "image" = "win11-23h2-pro"
    "size" = "Standard_B2s"
    "username" = "windows"
    "nsgName" = $nsg1ARG.name
  }
  
}

#######################   RESOURCE GROUP     #####################

  # New ResourceGroup
  $rg=New-AzResourceGroup `
    -Location $location `
    -Name $rgName

  $location=$rg.Location

######################   VIRTUAL NETWORKS    ######################

  # Create a new virtual network
  $vnet1=New-AzVirtualNetwork `
    -ResourceGroupName $rgName `
    -AddressPrefix $vnet1ARG.addressPrefix `
    -Location $location `
    -Name $vnet1ARG.name

  $vnet1=Get-AzVirtualNetwork -ResourceGroupName $rgName -Name $vnet1ARG.name
  # Get the default subnet: The default subnet is not created by default, it is just an ease thing in GUI.
  # $vnetSubnet1=Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name default

  # Create 1st subnet config
  $subnetI="subnet1"
  Add-AzVirtualNetworkSubnetConfig `
    -Name $vnet1ARG.$subnetI.name `
    -VirtualNetwork $vnet1 `
    -AddressPrefix $vnet1ARG.$subnetI.addressPrefix

  # Create 2nd subnet config
  $subnetI="subnet2"
  Add-AzVirtualNetworkSubnetConfig `
    -Name $vnet1ARG.$subnetI.name `
    -VirtualNetwork $vnet1 `
    -AddressPrefix $vnet1ARG.$subnetI.addressPrefix

  # Push the local vnet subnet config to Azure
  Set-AzVirtualNetwork -VirtualNetwork $vnet1

##############    Network Interface (NICs)   ####################
  
  # All the below methods will fail if Azure internally does not refreshes resources, tried sleep of 5 secs but it was not reliable.:
  # Pause for 5 seconds
  # "------PAUSING EXECUTION 5SEC FOR THE SUBNETS TO REFLECT IN COMMANDS----------"
  # Start-Sleep -Seconds 5
  # "------PAUSING EXECUTION FOR MANUAL REFRESH IN AZURE PORTAL----------"
  # Read-Host -Prompt "Press any key to continue or CTRL+C to quit" | Out-Null
  # Get the required subnet Id
  # $vnet1SubnetId=(Get-AzVirtualNetwork -ResourceGroupName $rgName -Name $vnet1ARG.name).Subnets[0].id   (This was more reliable)
  # $vnet1SubnetId=(Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet1 -Name $vnet1ARG.subnet1.name).Id
  # $vnet1SubnetId=($vnet1.Subnets[0]).Id

  # Get-AzVirtualNetwork -Name vnet1
  $vnet1 = Get-AzVirtualNetwork -ResourceGroupName $rgName -Name $vnet1ARG.name
  $vnet1SubnetId=$vnet1.Subnets[0].id
  # "------PRINTING SUBNET 1 OBJECT----------"
  # $vnet1SubnetId
  $nic_=$vmNICs.nic1.name
  New-AzNetworkInterface `
    -ResourceGroupName $vmNICs.resourceGroupName `
    -Location $vnet1.Location `
    -SubnetId $vnet1SubnetId `
    -IpConfigurationName $vmNICs.$nic_.ipConfigName `
    -Name $vmNICs.$nic_.name
  
  # Create NIC for subnet 2
  
  # $vnet1SubnetI=Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet1 -Name $vnet1ARG.subnet2.name
  $vnet1SubnetId=$vnet1.Subnets[1].id
  # "------PRINTING SUBNET 2 OBJECT----------"
  # $vnet1SubnetId
  $nic_=$vmNICs.nic2.name
  New-AzNetworkInterface `
    -ResourceGroupName $vmNICs.resourceGroupName `
    -Location $vnet1.Location `
    -SubnetId $vnet1SubnetId `
    -IpConfigurationName $vmNICs.$nic_.ipConfigName `
    -Name $vmNICs.$nic_.name


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
  
  Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg1

  # Apply the NSG to both the subnet 1 "config".
  $vnet1Subnet1 = Get-AzVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet1 `
    -Name $vnet1ARG.subnet1.name
  $vnet1Subnet1.NetworkSecurityGroup=$nsg1

  # Apply the NSG to both the subnet 2 "config".
  $vnet1Subnet2 = Get-AzVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet1 `
    -Name $vnet1ARG.subnet2.name
  $vnet1Subnet2.NetworkSecurityGroup=$nsg1

  # push "config" changes to Azure
  Set-AzVirtualNetwork -VirtualNetwork $vnet1


####################     VIRTUAL MACHINES    #####################
  # Get NIC Objects
  $nic1 = Get-AzNetworkInterface -ResourceGroupName $rgName -Name $vmNICs.nic1.name
  $nic2 = Get-AzNetworkInterface -ResourceGroupName $rgName -Name $vmNICs.nic2.name

  # Create a VM1 config
  "Enter credentaisl for the Windows virtual machine, same will be for vm2:"
  $creds = Get-Credential
  $vm="vm1"
  $vmConfig1 = New-AzVMConfig `
    -VMName $vmARG.$vm.name `
    -VMSize $vmARG.$vm.size
  $vmConfig1 = Set-AzVMOperatingSystem -VM $vmConfig1 `
    -Windows `
    -ComputerName $vmARG.$vm.name `
    -Credential $creds
  $vmConfig1 = Set-AzVMSourceImage -VM $vmConfig1 `
    -PublisherName "MicrosoftWindowsDesktop" `
    -Offer "Windows-11" `
    -Skus "win11-23h2-pro" `
    -Version "latest"
  $vmConfig1 = Add-AzVMNetworkInterface -VM $vmConfig1 `
    -Id $nic1.Id
  
  # Create a VM2 config with same credentials as of VM1
  $vmName = "VM2"
  $vmConfig2 = New-AzVMConfig `
    -VMName $vmName `
    -VMSize Standard_B2s
  $vmConfig2 = Set-AzVMOperatingSystem -VM $vmConfig2 `
    -Windows `
    -ComputerName VM2 `
    -Credential $creds
  $vmConfig2 = Set-AzVMSourceImage -VM $vmConfig2 `
    -PublisherName "MicrosoftWindowsDesktop" `
    -Offer "Windows-11" `
    -Skus "win11-23h2-pro" `
    -Version "latest"
  $vmConfig2 = Add-AzVMNetworkInterface -VM $vmConfig2 `
    -Id $nic2.Id
  
  # Finally create both the VMs
  New-AzVM `
    -ResourceGroupName $rgName `
    -Location $location `
    -VM $vmConfig1
  New-AzVM `
    -ResourceGroupName $rgName `
    -Location $location `
    -VM $vmConfig2

