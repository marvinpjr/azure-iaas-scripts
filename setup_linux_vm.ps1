#Networking for Linux VM
$sfx = "Two"
$pip2 = New-AzureRmPublicIpAddress `
        -ResourceGroupName $resourceGroup -Name "$pipName$sfx" `
        -Location $location -AllocationMethod Dynamic

$nic2 = New-AzureRmNetworkInterface `
        -ResourceGroupName $resourceGroup -Name "$nicName$sfx" `
        -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip2.Id

#associate to same nsg
$nic2.NetworkSecurityGroup = $nsg
$nic2 | Set-AzureRmNetworkInterface

$vm2 = New-AzureRmVMConfig `
        -VMName "$vmName$sfx" -VMSize "Basic_A1"

$vm2 = Set-AzureRmVMOperatingSystem `
        -VM $vm2 -Linux -ComputerName "$vmName$sfx" -Credential $cred

$vm2 = Set-AzureRmVMSourceImage `
        -VM $vm2 -PublisherName "Canonical" `
        -Offer "UbuntuServer" -Skus "18.04-LTS" -Version "latest"

$vm2 = Add-AzureRmVMNetworkInterface `
        -VM $vm2 -Id $nic2.Id

$osDiskUri2 = $storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + "$diskName$sfx" + ".vhd"

$vm2 = Set-AzureRmVMOSDisk `
        -VM $vm2 -Name "$diskName$sfx" -VhdUri $osDiskUri2 -CreateOption fromImage

New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vm2
