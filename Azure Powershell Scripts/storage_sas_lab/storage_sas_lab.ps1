
# Lab link: https://learn.microsoft.com/en-us/training/modules/control-access-to-azure-storage-with-sas/4-exercise-use-shared-access-signatures

$rgName = "newRgLab"
$rgLocation = "eastus"

$storageAccARG=@{
  "Name" = "medicalrecords11123"
  "Kind" = "StorageV2"
  "SkuName" = "Standard_LRS"
  "AccessTier" = "Hot"
  "Containers" = @{
    "Container1" = @{
      "name" = "patient-images"
    }
  }
}

# Step 1: Create a new storage account and Create a new storage container
  # create a new resource group
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
    # Get Context
    $ctx = New-AzStorageContext -StorageAccountName $storageAcc.StorageAccountName -UseConnectedAccount
    # create a new container for blob storage
    New-AzStorageContainer `
      -Context $ctx `
      -Name $storageAccARG.Containers.Container1.name
  } else {
    $storageAcc = $tmpStr
    # Get Context
    $ctx = New-AzStorageContext -StorageAccountName $storageAcc.StorageAccountName -UseConnectedAccount
  }

  # Step 2: Give permissions of for upload of blobs
    # Even if you have "(Inherited) Owner" role you need atleast a Non-Inherited "Storage Blob Data Contributor" for uploading files, you can give this role using GUI
  
  # Step 3: Bulk Upload image files to this container
  Get-ChildItem -File -Recurse | Set-AzStorageBlobContent -Container $storageAccARG.Containers.Container1.name -Context $ctx