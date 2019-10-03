Param
(
    [Parameter(Mandatory=$true)]
    [String]
    $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [String]
    $VnetName,
    [Parameter(Mandatory=$true)]
    [String]
    $Location,
    [Parameter(Mandatory=$true)]
    [String]
    $LoadBalancerName
)

$vnet = Get-AzureRmVirtualNetwork -Name $VnetName -ResourceGroupName $ResourceGroupName

Add-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $LoadBalancerName -AddressPrefix ""

$vnet = Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

$frontEndIp = New-AzureRmLoadBalancerFrontendIpConfig -Name $lbName -PrivateIpAddress 10.0.1.50 -SubnetId $vnet.Subnets[0].Id

$backEndPool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $LoadBalancerName

$healthProbe = New-AzureRmLoadBalancerProbeConfig -Name "$LoadBalancerName-probe" `
                                                -Protocol Tcp -Port 8080 `
                                                -IntervalInSeconds 10 -ProbeCount 3

$lbRule = New-AzureRmLoadBalancerRuleConfig -Name "HTTP" -FrontendIpConfigurationId $frontEndIp `
                                            -BackendAddressPoolId $backEndPool -Probe $healthProbe `
                                            -Protocol Tcp -FrontendPort 8080 -BackendPort 8080

New-AzureRmLoadBalancer -ResourceGroupName $ResourceGroupName -Location $Location -Name $LoadBalancerName `
                        -FrontendIpConfiguration $frontEndIp -BackendAddressPool $backEndPool `
                        -Probe $healthProbe -LoadBalancingRule $lbRule





