#Ref: https://learn.microsoft.com/en-us/training/modules/capture-application-logs-app-service/3-enable-and-configure-app-service-application-logging-using-the-azure-portal?tryIt=true&source=learn

$rgName="learn-dbc8338d-5628-43b4-ac13-230dd7ced949"
$location="australiacentral"
$aasARG=@{
	name="contosofashions111223"
	location=$location
	sourceCodeLocation="https://github.com/MicrosoftDocs/mslearn-capture-application-logs-app-service"
	asp=@{
		name="contosofashionsAppPlan"
    location=$location
	}
  logstrAcc=@{
    name = "sa"+$aasARG.name
    location=$location
    sku = "Standard_LRS"
  }
}

# create an ASP plan
az appservice plan create `
	--name $aasARG.asp.name `
	--resource-group $rgName `
	--location $aasARG.asp.location `
	--sku FREE

# create a AAS webapp
az webapp create `
	--name $aasARG.name`
	--resource-group $rgName `
	--plan $aasARG.asp.name `
	--deployment-source-url $aasARG.sourceCodeLocation

az storage account create `
	-n $aasARG.logstrAcc.name `
	-g $rgName `
	-l $aasARG.location `
	--sku $aasARG.logstrAcc.sku