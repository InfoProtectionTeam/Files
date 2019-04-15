"This Script will help you to install a basic instance of AIP scanner version 1.48 or higher in conjunction with the instructions at https://aka.ms/ScannerBlog"
""
"This script will do the following items in order"
""
" - Request the local AIP scanner service account credentials"
" - Request the name of your SQL server instance (use ServerName\SQLExpress for SQL Express instances)"
" - Request the name of your configured AIP scanner profile.  These can be configured in the Profiles section of the Azure AIP console (https://aka.ms/AIPConsole)"
" - Install the AIP scanner service with the provided profile"

Pause

Add-Type -AssemblyName Microsoft.VisualBasic

$scred = get-credential -Message "Enter Local AIP Scanner Service Account Credentials"

$SQL = [Microsoft.VisualBasic.Interaction]::InputBox('Enter the name of your SQL Server Instance', 'SQL Server Instance', "SQL01 or SQL01\SQLExpress")
	
$ScProfile = [Microsoft.VisualBasic.Interaction]::InputBox('Enter the name of your configured AIP Scanner Profile', 'AIP Scanner Profile', "East US")

"Installing AIP Scanner Service"	
Install-AIPScanner -ServiceUserCredentials $scred -SqlServerInstance $SQL -Profile $ScProfile
	
Pause
