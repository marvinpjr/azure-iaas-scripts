#create credential
$password = ConvertTo-SecureString $adminPassword -AsPlainText -Force
$cred = New-Object System.Management.Automation.PsCredential ($adminUserName, $password)