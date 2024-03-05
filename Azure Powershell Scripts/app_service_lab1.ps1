
# Give the names of the resources.
# Location is eastus for all
$rgName='newRg1'
$location='eastus'

$appServicePlanARG = @{
  "name" = "AppServicePlanDemo1"
  "Tier" = "Basic"
  "NumberofWorkers" = 2
  "WorkerSize" = "Small"
}

$appServiceARG = @{
  "name" = "AppServiceDemo11223"
}

# The source code of the application and approach of deployment.
$AppDeploymentObjectARG = @{
  repoUrl = "https://github.com/Azure-Samples/php-docs-hello-world";
  branch = "master";
  isManualIntegration = "true"; #we dont want to do contineous deployment that is why "true"
}

#######################   RESOURCE GROUP     #####################

  # New ResourceGroup
  New-AzResourceGroup `
    -Location $location `
    -Name $rgName

######################   APP SERVICE PLAN    ######################
# Unauthorized Error: 
# the script got stuck here, but from GUI it was working fine

  $appServicePlan = New-AzAppServicePlan `
    -Name $appServicePlanARG.name `
    -Location $location `
    -ResourceGroupName $rgName `
    -Tier $appServicePlanARG.Tier `
    -NumberofWorkers $appServicePlanARG.NumberofWorkers `
    -WorkerSize $appServicePlanARG.WorkerSize `
    -Debug

######################   AZURE APP SERVICE   ######################
  # Create a new app service resource.
  New-AzWebApp `
    -Name $appServiceARG.name `
    -AppServicePlan $appServicePlan.Name `
    -Location $appServicePlan.Location `
    -ResourceGroupName $rgName

  # Deploy the source code of the application to the above created "app service" resource
  Set-AzResource `
    -PropertyObject $AppDeploymentObjectARG  `
    -ResourceGroupName $rgName `
    -ResourceName $appServicePlanARG.name `
    -ResourceType Microsoft.Web/sites `
    -ApiVersion 2015-08-01 `
    -Force `
    -Debug
