#If you have not yet installed AutomatedLab, download the MSI from https://github.com/AutomatedLab/AutomatedLab/releases or run the PowerShell commands below.

Install-PackageProvider Nuget -Force
Install-Module AutomatedLab -AllowClobber
New-LabSourcesFolder -Drive C
Install-Module Az

#You will require ISO for Office 2019 placed in your C:\LabSources\ISOs\ folder. If the Office ISOs you use are not the same as the ones listed below, please update the script to match yours.

$labSources = Get-LabSourcesLocation -Local

#Download Software
$AzInfoProtectionFileName = 'AzInfoProtection_UL.exe'
$AzInfoProtectionFilePath = Join-Path -Path $labSources\SoftwarePackages -ChildPath $AzInfoProtectionFileName
$AzInfoProtectionUri = 'https://download.microsoft.com/download/4/9/1/491251F7-46BA-46EC-B2B5-099155DD3C27/AzInfoProtection_UL.exe'
if (-not (Test-Path -Path $AzInfoProtectionFilePath))
{
    Get-LabInternetFile -Uri $AzInfoProtectionUri -Path $AzInfoProtectionFilePath
}
$officeDeploymentToolFileName = 'OfficeDeploymentTool.exe'
$officeDeploymentToolFilePath = Join-Path -Path $labSources\SoftwarePackages -ChildPath $officeDeploymentToolFileName
$officeDeploymentToolUri = 'https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_12827-20268.exe'
if (-not (Test-Path -Path $officeDeploymentToolFilePath))
{
    Get-LabInternetFile -Uri $officeDeploymentToolUri -Path $officeDeploymentToolFilePath
}
$PIIZIPFileName = 'docs.zip'
$PIIZIPFilePath = Join-Path -Path $labSources\SoftwarePackages -ChildPath $PIIZIPFileName
$PIIZIPUri = 'https://github.com/InfoProtectionTeam/Files/raw/master/Scripts/docs.zip'
if (-not (Test-Path -Path $PIIZIPFilePath))
{
    Get-LabInternetFile -Uri $PIIZIPUri -Path $PIIZIPFilePath
}

$labName = 'AIPBYOL-KRM' #THIS NAME MUST BE GLOBALLY UNIQUE

$azureDefaultLocation = 'Central US' #COMMENT OUT -DefaultLocationName BELOW TO USE THE FASTEST LOCATION

#create an empty lab template and define where the lab XML files and the VMs will be stored
New-LabDefinition -Name $labName -DefaultVirtualizationEngine Azure

Add-LabAzureSubscription -DefaultLocationName $azureDefaultLocation

#make the network definition
Add-LabVirtualNetworkDefinition -Name $labname -AddressSpace 192.168.41.0/24 

#add the domain definition with the domain admin account
Add-LabDomainDefinition -Name contoso.azure -AdminUser Install -AdminPassword 'MIP4life!'

$ServerOS = 'Windows Server 2019 Datacenter (Desktop Experience)'
$ClientOS = 'Windows 10 Enterprise'
#--------------------------------------------------------------------------------------------------------------------
Set-LabInstallationCredential -Username Install -Password MIP4life!
Sync-LabAzureLabSources -SkipIsos
Sync-LabAzureLabSources -Filter *en_office_professional_plus_2019_x86_x64_dvd_7ea28c99* 

$postInstallActivity = Get-LabPostInstallationActivity -ScriptFileName PrepareRootDomain.ps1 -DependencyFolder $labSources\PostInstallationActivities\PrepareRootDomain
Add-LabMachineDefinition -Name ContosoDC -Roles RootDC -Memory 2GB -Processors 2 -OperatingSystem $ServerOS -IpAddress 192.168.41.10 -Network $labName -Domain contoso.azure -PostInstallationActivity $postInstallActivity
$postInstallActivity = Get-LabPostInstallationActivity -CustomRole Office2019 -Properties @{ IsoPath = "$labSources\ISOs\en_office_professional_plus_2019_x86_x64_dvd_7ea28c99.iso" }
$role = Get-LabMachineRoleDefinition -Role SQLServer2017
Add-LabMachineDefinition -Name AdminPC -Roles $role -Memory 2GB  -Processors 4 -OperatingSystem $ServerOS -IpAddress 192.168.41.50 -Network $labName -PostInstallationActivity $postInstallActivity -Domain contoso.azure
Add-LabMachineDefinition -Name ClientPC -OperatingSystem $ClientOS -IpAddress 192.168.41.51 -Network $labName -PostInstallationActivity $postInstallActivity -Domain contoso.azure

Install-Lab

#Install AIP UL Client on AdminPC (Optionally install on ClientPC by uncommenting. Left out so native functionality of Office Sensitivity Labeling will display)
Install-LabSoftwarePackage -Path $labSources\SoftwarePackages\AzInfoProtection_UL.exe -CommandLine /S -ComputerName AdminPC
#Install-LabSoftwarePackage -Path $labSources\SoftwarePackages\AzInfoProtection_UL.exe -CommandLine /S -ComputerName ClientPC

#Copy and extract PII docs on AdminPC
Invoke-LabCommand -ScriptBlock { md C:\PII } -ComputerName AdminPC
Copy-LabFileItem -Path $labSources\SoftwarePackages\docs.zip -ComputerName (Get-LabVm -ComputerName AdminPC) -DestinationFolderPath C:\PII
Invoke-LabCommand -ScriptBlock { Expand-Archive -LiteralPath C:\PII\docs.zip -DestinationPath C:\PII\ } -ComputerName AdminPC
Invoke-LabCommand -ScriptBlock { Expand-Archive -LiteralPath C:\PII\docs.zip -DestinationPath C:\Users\Public\Documents;New-SmbShare -Name Documents -Path C:\Users\Public\Documents -FullAccess Everyone} -ComputerName AdminPC

#Update Office 365 ProPlus
Invoke-LabCommand -ScriptBlock { Set-Location "C:\Program Files\Common Files\microsoft shared\ClickToRun\"; .\OfficeC2RClient.exe /update user } -ComputerName AdminPC,ClientPC

Show-LabDeploymentSummary -Detailed
