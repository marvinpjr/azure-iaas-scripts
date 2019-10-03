$ns = "mpdemo92"
$resourceGroup = "rg-$ns"
$location = "East US"
$nicName = "nic-$ns"
$pipName = "pip-$ns"
$vmName = "vm-$ns"

$diskName = "disk-$ns"
$nsgName = "nsg-$ns"
$storageAcctName = "sa$ns"
$adminUserName = "marvinpjr"
$adminPassword = ""
$myip = (Invoke-WebRequest -Uri "http://ipconfig.me/ip").Content