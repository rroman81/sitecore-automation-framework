Import-Module "$PSScriptRoot\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.sslCerts.prefix

GenerateRootCert -RootCertName "SitecoreRootCert_$prefix"
