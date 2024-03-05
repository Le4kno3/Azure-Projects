## Running in linux using Azure CLI
export APPNAME=$(az webapp list --query [0].name --output tsv)
export APPRG=$(az webapp list --query [0].resourceGroup --output tsv)
export APPPLAN=$(az appservice plan list --query [0].name --output tsv)
export APPSKU=$(az appservice plan list --query [0].sku.name --output tsv)
export APPLOCATION=$(az appservice plan list --query [0].location --output tsv)

az webapp up --name $APPNAME --resource-group $APPRG --plan $APPPLAN --sku $APPSKU --location "$APPLOCATION"


## Running in windows using Azure CLI
$APPNAME=az webapp list --resource-group newRg --query [0].name --output tsv
$APPRG=az webapp list --resource-group newRg --query [0].resourceGroup --output tsv
$APPPLAN=az appservice plan list --resource-group newRg --query [0].name --output tsv
$APPSKU=az appservice plan list --resource-group newRg --query [0].sku.name --output tsv
$APPLOCATION=az appservice plan list --resource-group newRg --query [0].location --output tsv

az webapp up --name $APPNAME --resource-group $APPRG --plan $APPPLAN --sku $APPSKU --location $APPLOCATION