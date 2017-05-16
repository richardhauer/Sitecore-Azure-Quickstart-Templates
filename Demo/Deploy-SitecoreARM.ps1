$ScriptRoot = "C:\Users\richard.hauer\Desktop\Trendspot\Sitecore-Azure-Quickstart-Templates\Demo"

#
# Login to Azure Subscription
#

$Password = Get-Content -Path $ScriptRoot\login-deets.txt
$AzureLogon = New-Object PSCredential -ArgumentList ("richard.hauer@ping-works.com.au", (ConvertTo-SecureString $Password -Force -AsPlainText))
Add-AzureRmAccount -TenantId "43fc635a-1903-4d53-841b-8e2278d05b94" -Credential $AzureLogon
Select-AzureRmSubscription -SubscriptionId "5eff103c-8503-4df6-9ec9-6cf7d9858af1" -TenantId "43fc635a-1903-4d53-841b-8e2278d05b94"

New-AzureRmResourceGroup -Name "trendspot" -Location SoutheastAsia

#
# Deploy Necessary pre-requisites: Storage account; Cosmos DB
#
New-AzureRmResourceGroupDeployment -Name "XP0-Prerequisites" `
									   -ResourceGroupName "trendspot" `
									   -TemplateFile "$ScriptRoot\..\XP0-Dependencies.json" `
									   -Force -Verbose -ErrorVariable ErrorMessages

Import-Module Azure.Storage | Out-Null

$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName "trendspot" -Name "trendspot"
$storageAccount.Context | New-AzureStorageContainer -Name "webdeploy" -Permission Blob
Start-AzureStorageBlobCopy -AbsoluteUri "https://pingworkscorp.blob.core.windows.net/trendspot/Sitecore%25208.2%2520rev.%2520170407_single.scwdp.zip" `
	-DestContainer "webdeploy" -DestBlob "Sitecore%25208.2%2520rev.%2520170407_single.scwdp.zip" -DestContext $storageAccount.Context
Start-AzureStorageBlobCopy -AbsoluteUri "https://pingworkscorp.blob.core.windows.net/trendspot/license.xml" `
	-DestContainer "webdeploy" -DestBlob "license.xml" -DestContext $storageAccount.Context

#
# Deploy_SitecoreARM.ps1
#

Import-Module "$ScriptRoot\..\..\Sitecore Azure Toolkit\tools\Sitecore.Cloud.Cmdlets.psm1" | Out-Null


Start-SitecoreAzureDeployment `
	-location australiasoutheast `
	-Name trendspot `
	-ArmTemplatePath "$ScriptRoot\..\Sitecore 8.2.3\xp0\azuredeploy.json"`
	-ArmParametersPath "$ScriptRoot\..\trendspot-823-xp0.parameters.json"`
	-LicenseXmlPath "$ScriptRoot\..\license.xml"`
	-SetKeyValue @{} `
	-Verbose
