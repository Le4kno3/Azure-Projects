# Create a new Azure container registry using GUI or use docker registry
$container = New-AzContainerInstanceObject -Name democontainer -Image alpine -Command "echo hello"

$containerGroup = New-AzContainerGroup -ResourceGroupName test-rg -Name test-cg -Location eastus -Container $container -OsType Linux