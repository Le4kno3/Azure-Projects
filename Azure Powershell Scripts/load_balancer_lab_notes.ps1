# Prepare
$rg=Get-AzResourceGroup -Name 'newRg'

# Command
New-AzPublicIpAddress `
	-Name NLBPublicIP `
	-ResourceGroupName $rg.ResourceGroupName `
	-Location $rg.Location `
	-Sku Basic `
	-AllocationMethod Static

# Prepare for NLB by creating backend pool config, health probe config and NLB rule
$frontendIP=New-AzLoadBalancerFrontendIpConfig -Name "NLBFrontendIP" -PublicIpAddress $publicIp

$backendPool = New-AzLoadBalancerBackendAddressPoolConfig -Name "myBackEndPool"

$probe = New-AzLoadBalancerProbeConfig `
  -Name "myHealthProbe" `
  -Protocol http `
  -Port 80 `
  -IntervalInSeconds 5 `
  -ProbeCount 2 `
  -RequestPath "/"

$nlbrule = New-AzLoadBalancerRuleConfig `
  -Name "myLoadBalancerRule" `
  -FrontendIpConfiguration $frontendIP `
  -BackendAddressPool $backendPool `
  -Protocol Tcp `
  -FrontendPort 80 `
  -BackendPort 80 `
  -Probe $probe

# Create the NLB now
$nlb = New-AzLoadBalancer `
-ResourceGroupName $rg.ResourceGroupName `
-Name 'MyLoadBalancer' `
-Location $rg.Location `
-FrontendIpConfiguration $frontendIP `
-BackendAddressPool $backendPool `
-Probe $probe `
-LoadBalancingRule $lbrule
-Sku Basic