# workshop-arc
Azure Workshop using a E8s_V3 - Nested Hyper-V with DC, FileServer, and Ubuntu. Can be used to create workshops involving Hybrid scenarios for customer to test like Arc, Backups, ASR, OMS, and other scenarios

PreReqs:

Azure Subscription, Azure Storage Explorer, Latest Azure PowerShell - https://github.com/Azure/azure-powershell/releases/

Deploy Lab:

Download and run the AzureArcWorkShopLab.ps1, script is interactive for Authentication and Subscription Selection, Location is set to East US where VM family Es_V3 is avaliable. Testing script takes roughly 30 minutes or so to execute, due to vhd copying. Need to rewrite ARM deployment to somthing like: https://github.com/microsoft/DefendTheFlag 

Enviroment Details:
Domain: AzureLab.local
User: azurelab
Pass: Microsoft84!

Links: 

Disks: https://azuworkshop.blob.core.windows.net/workshop-arc

Nested Azure Hyper-V: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/nested-virtualization

Need 2nd Layer VM to respond on VNET Resources ?: https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/nested-virtualization-azure-virtual-network
