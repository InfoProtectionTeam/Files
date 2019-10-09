"This Script will help you to create a cloud service account for use with the AIP scanner"
"This script SHOULD NOT be used if you are using Azure AD Sync to sync your on premises account"
"This should be used in conjunction with the instructions at https://aka.ms/ScannerBlog"
""
"This script will do the following items in order"
""
" - Import or Install then Import the Azure AD PowerShell Module"
" - Log in using Azure Global Admin credentials"

Pause

if (Get-InstalledModule -Name "AzureAD" -ErrorAction SilentlyContinue) {
    "Importing Azure AD Module"
    Import-Module -Name "AzureAD"
} else {
    "Installing Azure AD Module"
    Install-Module -Name "AzureAD"
    "Importing Azure AD Module"
    Import-Module -Name "AzureAD"
}

$gacred = get-credential -Message "Enter Azure Global Admin Credentials"

"Connecting to Azure AD"
Connect-AzureAD -Credential $gacred

$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile 
$PasswordProfile.ForceChangePasswordNextLogin = $false 
$Password = Read-Host -assecurestring "Please enter password for cloud service account" 
$SecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)) 
$PasswordProfile.Password = $SecurePassword

$Tenant = Read-Host "Please enter tenant name for UserPrincipalName (e.g. contoso.com)" 
New-AzureADUser -AccountEnabled $True -DisplayName "AIP Scanner Cloud Service" -PasswordProfile $PasswordProfile -MailNickName "AIPScannerCloud" -UserPrincipalName "AIPScannerCloud@$Tenant"
