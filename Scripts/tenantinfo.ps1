"Enter Domain Name (e.g. AIPDemo.com)"
$domain = Read-Host
$config = (Invoke-WebRequest –Uri "https://login.microsoftonline.com/$domain/.well-known/openid-configuration").content | ConvertFrom-Json

"$domain configuration"
""
"Tenant Id"
($config.token_endpoint -split('/'))[3]
""
"Region"
$config.tenant_region_scope