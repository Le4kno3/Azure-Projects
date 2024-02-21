#!/bin/bash

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
  # RgName=`az group list --query '[0].name' --output tsv`
  Location=`az group show --resource-group $RgName --query location`
  Location=${Location:1:-1}
  name='bePortal'
  avail_set_name='portalAvailabilitySet'
  username="azureuser"
  vmImage="Ubuntu2204"

  date
  # Create a Virtual Network for the VMs
  echo '------------------------------------------'
  echo 'Creating a Virtual Network for the VMs'
  az network vnet create \
      --resource-group $RgName \
      --location $Location \
      --name "$name"Vnet \
      --subnet-name  "$name"Subnet

  # Create a Network Security Group
  echo '------------------------------------------'
  echo 'Creating a Network Security Group'
  az network nsg create \
      --resource-group $RgName \
      --name "$name"NSG \
      --location $Location

  az network nsg rule create -g $RgName --nsg-name "$name"NSG -n AllowAll80 --priority 101 \
                              --source-address-prefixes 'Internet' --source-port-ranges '*' \
                              --destination-address-prefixes '*' --destination-port-ranges 80 --access Allow \
                              --protocol Tcp --description "Allow all port 80 traffic"


  # Create the NIC
  for i in `seq 1 2`; do
    echo '------------------------------------------'
    echo 'Creating webNic'$i
    az network nic create \
      --resource-group $RgName \
      --name webNic$i \
      --vnet-name "$name"Vnet \
      --subnet "$name"Subnet \
      --network-security-group "$name"NSG \
      --location $Location
  done 

  # Create an availability set
  echo '------------------------------------------'
  echo 'Creating an availability set'
  az vm availability-set create \
      --resource-group $RgName \
      --name $avail_set_name

  # Create 2 VM's from a template
  for i in `seq 1 2`; do
      echo '------------------------------------------'
      echo 'Creating webVM'$i
      az vm create \
          --admin-username $username \
          --resource-group $RgName \
          --name webVM$i \
          --nics webNic$i \
          --location $Location \
          --image $vmImage \
          --availability-set $avail_set_name \
          --generate-ssh-keys \
          --custom-data cloud-init.txt
  done

  # Done
  echo '--------------------------------------------------------'
  echo '             VM Setup Completed'
  echo '--------------------------------------------------------'

  echo '--------------------------------------------------------'
  echo '             Starting Load Balancer Deploy'
  echo '--------------------------------------------------------'


      az network public-ip create \
        --resource-group $RgName \
        --location $Location \
        --allocation-method Static \
        --name myPublicIP \
        --sku Standard

    az network lb create \
        --resource-group $RgName \
        --name myLoadBalancer \
        --public-ip-address myPublicIP \
        --frontend-ip-name myFrontEndPool \
        --backend-pool-name myBackEndPool \
        --sku Standard

    az network lb probe create \
      --resource-group $RgName \
      --lb-name myLoadBalancer \
      --name myHealthProbe \
      --protocol tcp \
      --port 80

    az network lb rule create \
        --resource-group $RgName \
        --lb-name myLoadBalancer \
        --name myHTTPRule \
        --protocol tcp \
        --frontend-port 80 \
        --backend-port 80 \
        --frontend-ip-name myFrontEndPool \
        --backend-pool-name myBackEndPool

    az network nic ip-config update \
        --resource-group $RgName \
        --nic-name webNic1 \
        --name ipconfig1 \
        --lb-name myLoadBalancer \
        --lb-address-pools myBackEndPool

    az network nic ip-config update \
        --resource-group $RgName \
        --nic-name webNic2 \
        --name ipconfig1 \
        --lb-name myLoadBalancer \
        --lb-address-pools myBackEndPool

    az network public-ip show \
        --resource-group $RgName \
        --name myPublicIP \
        --query [ipAddress] \
        --output tsv

  echo '--------------------------------------------------------'
  echo '  Load balancer deployed to the IP Address shown above'
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