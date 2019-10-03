#setup resource group
New-AzureRmResourceGroup `
        -Name $resourceGroup -Location $location

#setup storage account
New-AzureRmStorageAccount `
        -Name $storageAcctName -ResourceGroupName $resourceGroup `
        -Type Standard_LRS -Location $location

$storageAcc = Get-AzureRmStorageAccount `
        -ResourceGroupName $resourceGroup -Name $storageAcctName
$osDiskUri = $storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskName + ".vhd"