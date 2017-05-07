#
# Deploy_SitecoreARM.ps1
#

Import-Module "$PSScriptRoot\..\..\Sitecore Azure Toolkit\tools\Sitecore.Cloud.Cmdlets.psm1"

$Password = Get-Content -Path $PSScriptRoot\login-deets.txt
$AzureLogon = New-Object PSCredential -ArgumentList ("richard.hauer@ping-works.com.au", (ConvertTo-SecureString $Password -Force -AsPlainText))
Add-AzureRmAccount -TenantId "45812c87-cdab-423a-8ac1-f00f20d60dee" -Credential $AzureLogon
Select-AzureRmSubscription -SubscriptionName "Free Trial"

Start-SitecoreAzureDeployment `
	-location australiasoutheast `
	-Name trendspot `
	-ArmTemplatePath "$PSScriptRoot\..\Sitecore 8.2.3\xp0\azuredeploy.json"`
	-ArmParametersPath "$PSScriptRoot\..\trendspot-823-xp0.parameters.json"`
	-LicenseXmlPath "$PSScriptRoot\..\license.xml"`
	-SetKeyValue @{}

[System.Windows.MessageBox]::Show( "Deployment script finished", "Sitecore deployment",'Ok','Information')