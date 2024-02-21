#!/bin/bash
# Usage: bash create-high-availability-vm-with-sets.sh <Resource Group Name>

Help(){
   # Display Help
   echo "Script that creates environment for NLB tutorial (1 VNet, 2 Linux VMs, 2 NICs, 1 NSG)."
   echo
   echo "Syntax: scriptTemplate [-h] [-g <ResourceGroupName>] ]"
   echo "options:"
   echo "h     Print this Help."
   echo "g     You need to specify the required <ResourceGroupName> parameter"
   echo
}


RunScript(){
  # RgName=$1
  VNetName="bePortalVnet"
  VNetSubnetName="bePortalSubnet"
  NSGName="bePortalNSG"
  AvailabilitySetName="portalAvailabilitySet"
  VMImageName="Ubuntu2204"
  VMUser="linux"
  
  date
  echo ""
  echo "The resource group name is: $RgName"
  echo ""
  # Create a Virtual Network for the VMs
  echo '------------------------------------------'
  echo 'Creating a Virtual Network for the VMs'
  az network vnet create \
      --resource-group $RgName \
      --name $VNetName \
      --subnet-name $VNetSubnetName

  # Create a Network Security Group
  echo '------------------------------------------'
  echo 'Creating a Network Security Group'
  az network nsg create \
      --resource-group $RgName \
      --name $NSGName

  # Add inbound rule on port 80
  echo '------------------------------------------'
  echo 'Allowing access on port 80'
  az network nsg rule create \
      --resource-group $RgName \
      --nsg-name $NSGName \
      --name Allow-80-Inbound \
      --priority 110 \
      --source-address-prefixes '*' \
      --source-port-ranges '*' \
      --destination-address-prefixes '*' \
      --destination-port-ranges 80 \
      --access Allow \
      --protocol Tcp \
      --direction Inbound \
      --description "Allow inbound on port 80."

  # Create the NIC
  for i in `seq 1 2`; do
    echo '------------------------------------------'
    echo 'Creating webNic'$i
    az network nic create \
      --resource-group $RgName \
      --name webNic$i \
      --vnet-name $VNetName \
      --subnet $VNetSubnetName \
      --network-security-group $NSGName
  done 

  # Create an availability set
  echo '------------------------------------------'
  echo 'Creating an availability set'
  az vm availability-set create -n $AvailabilitySetName -g $RgName

  # Create 2 Linux VM's from a template
  for i in `seq 1 2`; do
      echo '------------------------------------------'
      echo 'Creating webVM'$i
      az vm create \
          --admin-username $VMUser \
          --resource-group $RgName \
          --name webVM$i \
          --nics webNic$i \
          --image $VMImageName \
          --availability-set $AvailabilitySetName \
          --generate-ssh-keys \
          --custom-data cloud-init.txt
  done

  # Done
  echo '--------------------------------------------------------'
  echo '             VM Setup Script Completed'
  echo '--------------------------------------------------------'
}


# Get the options
while getopts ":h:r:g:" option; do
   case $option in
      h) 
         Help
         exit;;
      g)
        RgName="$OPTARG"
        RunScript;;
   esac
done



