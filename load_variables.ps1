$ns = "mpdemo92"
$resourceGroup = "rg-$ns"
$location = "East US"
$nicName = "nic-$ns"
$pipName = "pip-$ns"
$vmName = "vm-$ns"

$diskName = "disk-$ns"
$nsgName = "nsg-$ns"
$adminUserName = "marvinpjr"
$adminPassword = "AjskdlfQuwieor!23"
$myip = (Invoke-WebRequest -Uri "http://ipconfig.me/ip").Content