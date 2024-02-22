# Create a new route table
$routeTable = New-AzRouteTable `
	-Name publictable `
	-ResourceGroupName newRg `
	-DisableBgpRoutePropagation

# create a new routing rule for the above routing table.
Add-AzRouteConfig -RouteTable $routeTable `
	-Name "productionsubnet" `
	-AddressPrefix 10.0.1.0/24 `
	-NextHopType VirtualAppliance `
	-NextHopIpAddress 10.0.2.4

# Push these local "config" changes to Azure
Set-AzRouteTable -RouteTable $routeTable

# create a new vnet
$vnet=New-AzVirtualNetwork `
	-Name vnet `
	-ResourceGroupName newRg `
	-AddressPrefix 10.0.0.0/16 `
	-Location eastus

# create subnet 1
Add-AzVirtualNetworkSubnetConfig `
	-Name publicsubnet `
	-AddressPrefix 10.0.0.0/24 `
	-VirtualNetwork $vnet

# create subnet 2
Add-AzVirtualNetworkSubnetConfig `
	-Name privatesubnet `
	-AddressPrefix 10.0.1.0/24 `
	-VirtualNetwork $vnet

# create subnet 3
Add-AzVirtualNetworkSubnetConfig `
	-Name dmzsubnet `
	-AddressPrefix 10.0.2.0/24 `
	-VirtualNetwork $vnet

# Associate the newly create route table with the "publicsubnet"
Set-AzVirtualNetworkSubnetConfig `
	-Name $subnet.Name `
	-VirtualNetwork $vnet `
	-RouteTable $routeTable `
	-AddressPrefix 10.0.0.0/24

# Push the local config changes to Azure
Set-AzVirtualNetwork -VirtualNetwork $vnet