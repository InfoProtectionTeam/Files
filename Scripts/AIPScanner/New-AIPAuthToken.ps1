"This Script will help you to create the necessary Azure AD Applications to install a basic instance of AIP scanner"
"This requires AIP Client version 1.48 or higher and should be used in conjunction with the instructions at https://aka.ms/ScannerBlog"
""
"This script will request the following items in order"
""
" - Import or Install then Import the Azure AD PowerShell Module"
" - Log in using Azure Global Admin credentials"
" - Create 1 Web Application and Associated Key"
" - Create 1 Native Application"
" - Generate an Authentication Token Script"

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

$Date = Get-Date -UFormat %m%d%H%M
$DisplayName = "AIPOBO-" + $Date
$CKI = "AIPClient-" + $Date

"Creating Azure AD Applications. This may take 1-2 minutes."	
"Creating Web Application $DisplayName and Secret key with one year expiration "
New-AzureADApplication -DisplayName $DisplayName -ReplyUrls http://localhost
$WebApp = Get-AzureADApplication -Filter "DisplayName eq '$DisplayName'"
New-AzureADServicePrincipal -AppId $WebApp.AppId
$WebAppKey = New-Guid
$Date = Get-Date
New-AzureADApplicationPasswordCredential -ObjectId $WebApp.ObjectID -startDate $Date -endDate $Date.AddYears(1) -Value $WebAppKey.Guid -CustomKeyIdentifier $CKI

"Creating RequiredResourceAccess token for use with permissions assignment"
$AIPServicePrincipal = Get-AzureADServicePrincipal -All $true | Where-Object { $_.DisplayName -eq $DisplayName }
$AIPPermissions = $AIPServicePrincipal | Select-Object -expand Oauth2Permissions
$Scope = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $AIPPermissions.Id, "Scope"
$Access = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
$Access.ResourceAppId = $WebApp.AppId
$Access.ResourceAccess = $Scope

"Creating Native Application $CKI"
New-AzureADApplication -DisplayName $CKI -ReplyURLs http://localhost -RequiredResourceAccess $Access -PublicClient $true
$NativeApp = Get-AzureADApplication -Filter "DisplayName eq '$CKI'"
New-AzureADServicePrincipal -AppId $NativeApp.AppId

"Generating Authenitcation Token script for AIP Scanner Service"    
Start-Sleep -Seconds 5
"Set-AIPAuthentication -WebAppID " + $WebApp.AppId + " -WebAppKey " + $WebAppKey.Guid + " -NativeAppID " + $NativeApp.AppId | Out-File ~\Desktop\Set-AIPAuthentication.txt
""
"Authenitcation Token script stored on the desktop as Set-AIPAUthentication.txt"
""
"Follow the instructions at https://aka.ms/ScannerBlog to install the service"
""
"Run the commands below to complete your AIP scanner installation"
""
"In the context of the AIP service account, run the Set-AIPAuthentication command stored in the text file"
"When prompted, sign in using the cloud or synced AIP scanner service account"
""
"In an Admin PowerShell prompt, run the command below"
"Restart-Service AIPScanner"
"Start-AIPScan"
Pause
