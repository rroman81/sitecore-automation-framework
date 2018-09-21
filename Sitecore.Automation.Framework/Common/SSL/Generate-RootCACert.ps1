Import-Module "$PSScriptRoot\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix

GenerateRootCert -Prefix $prefix
