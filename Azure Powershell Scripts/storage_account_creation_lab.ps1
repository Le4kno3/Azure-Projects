
$rgName = "newRg"
$rgLocation = "eastus"

$storageAccARG=@{
  "Name" = "kpatilstorageaccount1"
  "Kind" = "StorageV2"
  "SkuName" = "Standard_LRS"
  "AccessTier" = "Hot"
  "Containers" = @{
    "Container1" = @{
      "name" = "container1demo"
    }
  }
  "Fileshares" = @{
    "Fileshare1" = @{
      "name" = "fileshare1demo"
    }
  }
}

# Create a new storage account
New-AzResourceGroup -Name $rgName -Location $rgLocation

# Check if storage account is already created? This is an extra thing as storage account names has to be globally unique.
$tmpStr = Get-AzStorageAccount -Name $storageAccARG.Name -ResourceGroupName $rgName
if($tmpStr.ProvisioningState -ne "Succeeded"){
  # Create a new azure storage
  $storageAcc = New-AzStorageAccount `
    -ResourceGroupName $rgName `
    -SkuName $storageAccARG.SkuName `
    -Location $rgLocation `
    -AccessTier $storageAccARG.AccessTier `
    -Name $storageAccARG.Name
} else {
  $storageAcc = $tmpStr
}

# Get Context
$ctx = New-AzStorageContext -StorageAccountName $storageAcc.StorageAccountName -UseConnectedAccount

# Create a new storage container
New-AzStorageContainer `
  -Context $ctx `
  -Name $storageAccARG.Containers.Container1.name

# Create a new file share
New-AzRmStorageShare `
    -StorageAccount $storageAcc `
    -Name $storageAccARG.Fileshares.Fileshare1.name `
    -EnabledProtocol SMB `
    -QuotaGiB 1024 | Out-Null