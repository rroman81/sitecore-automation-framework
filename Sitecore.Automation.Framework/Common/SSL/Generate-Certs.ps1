Import-Module "$PSScriptRoot\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$hostNames = $global:Configuration.hostNames

GenerateServerCert -Prefix $prefix -Hostnames $hostNames
GenerateClientCert -Prefix $prefix -Hostnames $hostNames