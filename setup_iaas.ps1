Param(
    [Parameter(Mandatory=$true)]
    [String]
    $NameSpace,
    [Parameter(Mandatory=$true)]
    [String]
    $UserName,
    [Parameter(Mandatory=$true)]
    [String]
    $Password,
    [Parameter(Mandatory=$true)]
    [String]
    $Location = "East US 2",
    [Parameter(Mandatory=$true)]
    [Int32]
    $NumberOfVMs = 1
)

#Install-Module AzureRM #if you haven't
#Import-Module AzureRM
#Login-AzureRmAccount

$ResoureGroupName = "rg-$NameSpace"
$vmName = "vm-$ns"

$diskName = "disk-$ns"
$nsgName = "nsg-$ns"
$strNm = "sa$ns"
$adminUserName = $UserName
$adminPassword = $Password
$myip = (Invoke-WebRequest -Uri "http://ipconfig.me/ip").Content

Clear-Host

#create credential
$cred = Create-Credential -uid $UserName -pw $Password

#create resource group and storage
$rg = Create-ResourceGroup -rgName $ResoureGroupName
Create-StorageAcct -resourceGroupName $ResoureGroupName -storageAcctName $strNm

#setup networking
$networkInterface = Create-VirtualNetworkReturnInterface -resourceGroupName $ResoureGroupName -location $Location `
    -nameSpace $NameSpace -ipAddress $myip

#setup windows vm
$winVM = Create-VM -resourceGroupName $rgNm -vmName $vmName -cred $cred -networkInterface $networkInterface

#setup linux vm
. .\setup_linux_vm.ps1

Function Create-Credential
{
    param([string]$uid,[string]$pw)

    #create credential
    $password = ConvertTo-SecureString $pw -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PsCredential ($uid, $pw)
    
    return $cred
}

Function Create-ResourceGroup
{
    param([string]$rgName)

    #setup resource group
    $rg = New-AzureRmResourceGroup `
            -Name $resourceGroup -Location $location

    return $rg
}

Function Create-StorageAcct
{
    param([string]$resourceGroupName, [string]$storageAcctName)

    #setup storage account
    New-AzureRmStorageAccount `
            -Name $storageAcctName -ResourceGroupName $resourceGroupName `
            -Type Standard_LRS -Location $location

    $storageAcc = Get-AzureRmStorageAccount `
            -ResourceGroupName $resourceGroupName -Name $storageAcctName
    $osDiskUri = $storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskName + ".vhd" 
}

Function Create-VirtualNetworkReturnInterface
{
    param(
        [Parameter(Mandatory=$true)]
        [String]
        $resourceGroupName,
        [Parameter(Mandatory=$true)]
        [String]
        $location,
        [Parameter(Mandatory=$true)]
        [String]
        $ipAddress
    )


    #setup vnet, public ip
    $subnet = New-AzureRmVirtualNetworkSubnetConfig `
            -Name "sn-$NameSpace" -AddressPrefix 10.0.1.0/24

    $vnet = New-AzureRmVirtualNetwork `
            -Name "vn-$NameSpace" -ResourceGroupName $resourceGroupName -Location $location `
            -AddressPrefix 10.0.0.0/16 -Subnet $subnet                                  

    $pip = New-AzureRmPublicIpAddress `
            -Name "$NameSpace-pip" -ResourceGroupName $resourceGroupName `
            -Location $location -AllocationMethod Dynamic

    #create nic, nsg, and inbound rules 
    $nic = New-AzureRmNetworkInterface `
            -Name "nic-$NameSpace" -ResourceGroupName $resourceGroupName `
            -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

    $rdprule = New-AzureRmNetworkSecurityRuleConfig `
            -Name rdp-rule -Description "Allow RDP" `
            -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
            -SourceAddressPrefix $ipAddress -SourcePortRange * `
            -DestinationAddressPrefix * -DestinationPortRange 3389

    $httprule = New-AzureRmNetworkSecurityRuleConfig `
            -Name http-rule -Description "Allow HTTP" `
            -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 `
            -SourceAddressPrefix $ipAddress -SourcePortRange * `
            -DestinationAddressPrefix * -DestinationPortRange 80

    $sshrule = New-AzureRmNetworkSecurityRuleConfig `
            -Name ssh-rule -Description "Allow SSH" `
            -Access Allow -Protocol Tcp -Direction Inbound -Priority 102 `
            -SourceAddressPrefix $ipAddress -SourcePortRange * `
            -DestinationAddressPrefix * -DestinationPortRange 22

    $nsg = New-AzureRmNetworkSecurityGroup `
            -ResourceGroupName $resourceGroupName -Location $location -Name "$NameSpace-nsg" `
            -SecurityRules $rdprule, $httprule, $sshrule                               

    $nic.NetworkSecurityGroup = $nsg
    $nic | Set-AzureRmNetworkInterface

    return $nic
}

Function Create-VM
{
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $resourceGroupName,
        [Parameter(Mandatory=$true)]
        [String]
        $vmName,
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PsCredential]
        $cred,
        [Parameter(Mandatory=$true)]
        [String]
        $networkInterface,
        [Parameter(Mandatory=$true)]
        [Microsoft.Azure.Commands.Network.Models.PSNetworkInterface]
        $Publisher = "MicrosoftWindowsServer",
        [Parameter(Mandatory=$true)]
        [String]
        $vmSize = "Basic_A1",
        [Parameter(Mandatory=$true)]
        [String]
        $Offer = "WindowsServer",
        [Parameter(Mandatory=$true)]
        [String]
        $Sku ="2012-R2-Datacenter"
    )

    #setup Windows VM                                   
    $vm = New-AzureRmVMConfig `
            -VMName $vmName -VMSize $vmSize

    $vm = Set-AzureRmVMOperatingSystem `
            -VM $vm -Windows -ComputerName $vmName -Credential $cred `
            -ProvisionVMAgent -EnableAutoUpdate

    $vm = Set-AzureRmVMSourceImage `
            -VM $vm -PublisherName $Publisher `
            -Offer $Offer -Skus $Sku -Version "latest"

    $vm = Add-AzureRmVMNetworkInterface `
            -VM $vm -Id $networkInterface.Id

    $vm = Set-AzureRmVMOSDisk `
            -VM $vm -Name $diskName -VhdUri $osDiskUri -CreateOption fromImage

    New-AzureRmVM `
            -ResourceGroupName $resourceGroupName -Location $location -VM $vm    
}
