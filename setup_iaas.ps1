#Install-Module AzureRM #if you haven't
#Import-Module AzureRM
#Login-AzureRmAccount
# ."C:\Users\Marvin\Desktop\Azure Devops Demo\setup_windows_vm.ps1"

Clear-Host

#load variables
. .\load_variables.ps1

#create credential
. .\create_credential.ps1

#create resource group and storage
. .\create_resourcegroup_and_storage.ps1

#setup networking
. .\setup_networking.ps1

#setup windows vm
. .\setup_windows_vm.ps1

#setup linux vm
. .\setup_linux_vm.ps1