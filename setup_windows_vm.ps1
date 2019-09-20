#setup Windows VM                                   
$vm = New-AzureRmVMConfig `
        -VMName $vmName -VMSize "Basic_A1"

$vm = Set-AzureRmVMOperatingSystem `
        -VM $vm -Windows -ComputerName $vmName -Credential $cred `
        -ProvisionVMAgent -EnableAutoUpdate

$vm = Set-AzureRmVMSourceImage `
        -VM $vm -PublisherName "MicrosoftWindowsServer" `
        -Offer "WindowsServer" -Skus "2012-R2-Datacenter" -Version "latest"

$vm = Add-AzureRmVMNetworkInterface `
        -VM $vm -Id $nic.Id

$vm = Set-AzureRmVMOSDisk `
        -VM $vm -Name $diskName -VhdUri $osDiskUri -CreateOption fromImage

New-AzureRmVM `
        -ResourceGroupName $resourceGroup -Location $location -VM $vm    
