#create availability set
$availabilitySet = New-AzureRmAvailabilitySet -ResourceGroupName $resourceGroup -Location $location -Name "iaas-avset"

#setup vnet, public ip
$subnet = New-AzureRmVirtualNetworkSubnetConfig `
        -Name "sn-$ns" -AddressPrefix 10.0.1.0/24

$vnet = New-AzureRmVirtualNetwork `
        -Name "vn-$ns" -ResourceGroupName $resourceGroup -Location $location `
        -AddressPrefix 10.0.0.0/16 -Subnet $subnet                                  

$pip = New-AzureRmPublicIpAddress `
        -Name $pipName -ResourceGroupName $resourceGroup `
        -Location $location -AllocationMethod Dynamic

#create nic, nsg, and inbound rules 
$nic = New-AzureRmNetworkInterface `
        -Name $nicName -ResourceGroupName $resourceGroup `
        -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

$rdprule = New-AzureRmNetworkSecurityRuleConfig `
        -Name rdp-rule -Description "Allow RDP" `
        -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
        -SourceAddressPrefix $myip -SourcePortRange * `
        -DestinationAddressPrefix * -DestinationPortRange 3389

$httprule = New-AzureRmNetworkSecurityRuleConfig `
        -Name http-rule -Description "Allow HTTP" `
        -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 `
        -SourceAddressPrefix $myip -SourcePortRange * `
        -DestinationAddressPrefix * -DestinationPortRange 80

$sshrule = New-AzureRmNetworkSecurityRuleConfig `
        -Name ssh-rule -Description "Allow SSH" `
        -Access Allow -Protocol Tcp -Direction Inbound -Priority 102 `
        -SourceAddressPrefix $myip -SourcePortRange * `
        -DestinationAddressPrefix * -DestinationPortRange 22

$nsg = New-AzureRmNetworkSecurityGroup `
        -ResourceGroupName $resourceGroup -Location $location -Name $nsgName `
        -SecurityRules $rdprule, $httprule, $sshrule                               

$nic.NetworkSecurityGroup = $nsg
$nic | Set-AzureRmNetworkInterface