#[CmdletBinding()]
#Param(
#  [Parameter(Mandatory=$True,Position=1)]
#   [string]$Loc #,
	
   #[Parameter(Mandatory=$True)]
   #[string]$SubId
#)

$Loc = "EastUS"

## Script roughly takes 30 minutes to setup lab and complete

$date = Get-Date
Write-host $date

#Login and Authenticate

Login-AzAccount

# Present and Select Azure Subscription to deploy Lab into 

$SubId = Get-AzSubscription | Out-GridView -PassThru

$SubId = $SubId.SubscriptionId

Select-AzSubscription -SubscriptionId $SubId

# Generate random unique string for storage and ResourceGroup

$digit = -join ((65..90) + (97..122) | Get-Random -Count 3 | % {[char]$_})

$digit = $digit.ToLower()

Write-Host "You unique 3 letter digit is: " + $digit

$RG = "RG-" + $digit + "-AzureArcLab"

Write-Host "Your ResourceGroup is: " + $RG

# Create ResourceGroup to create storage, copy disks and deploy lad into

New-AzResourceGroup -Name $RG -Location $Loc

# Create new storage account with unique string

$storename = $digit + "azulabstore"

$storageAccount = New-AzStorageAccount -ResourceGroupName $RG -Name $storename -SkuName "Premium_LRS" -Location $loc

$storekey = Get-AzStorageAccountKey -ResourceGroupName $RG -Name $storename
$storekey = $storekey[0].Value

#Create the context for the storage account which will be used to copy snapshot to the storage account 

$destinationContext = New-AzStorageContext –StorageAccountName $storename -StorageAccountKey $storekey 

$containername = "labdisks"
New-AzStorageContainer -Context $destinationContext -Name $containername

#Copy the snapshots to the storage account 

Start-AzStorageBlobCopy -SrcUri https://azuworkshop.blob.core.windows.net/workshop-arc2/DC.vhd -DestContainer $containername -DestContext $destinationContext -DestBlob DC.vhd
Start-AzStorageBlobCopy -SrcUri https://azuworkshop.blob.core.windows.net/workshop-arc2/FS.vhd -DestContainer $containername -DestContext $destinationContext -DestBlob FS.vhd
Start-AzStorageBlobCopy -SrcUri https://azuworkshop.blob.core.windows.net/workshop-arc2/UBUNTU.vhd -DestContainer $containername -DestContext $destinationContext -DestBlob UBUNTU.vhd
Start-AzStorageBlobCopy -SrcUri https://azuworkshop.blob.core.windows.net/workshop-arc2/LABVM.vhd -DestContainer $containername -DestContext $destinationContext -DestBlob LABVM.vhd

#Future build logic to conditional check async maybe do loop and then allow exit into deployment phase once all copies are done, 
#also try catch exit on a copy error

Get-AzStorageBlobCopyState -Blob LABVM.vhd -Container $containername -Context $destinationContext -WaitForComplete

$date = Get-Date
Write-host $date

#Obtain your Public IP for Allow RDP to only you on NSG

$yourpip = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip

# Deploy LabVM enviroment

New-AzResourceGroupDeployment -Name LabVMDeployment -ResourceGroupName $RG -Mode Incremental -TemplateUri 'https://raw.githubusercontent.com/swiftsolves-msft/workshop-arc/master/AzureArcWorkshop.json' -storageAccountName $storename -rgname $RG -YourPublicIP $yourpip

#Launch WorkShop RG in portal.azure.com for Fun to begin :) 

$Browser=new-object -com internetexplorer.application

$URL = "https://ms.portal.azure.com/#resource/subscriptions/" + $SubId + "/resourceGroups/" + $RG + "/overview"
$Browser.navigate2($URL)
$Browser.visible=$true

$date = Get-Date
Write-host $date

# Future Build when specialized is supported through PS creation or using Azure Image Service
