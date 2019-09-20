#setup resource group
New-AzureRmResourceGroup `
        -Name $resourceGroup -Location $location

#setup storage account
New-AzureRmStorageAccount `
        -Name "sa$ns" -ResourceGroupName $resourceGroup `
        -Type Standard_LRS -Location $location

$storageAcc = Get-AzureRmStorageAccount `
        -ResourceGroupName $resourceGroup -Name "sa$ns"
$osDiskUri = $storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskName + ".vhd"