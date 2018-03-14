Import-Module "$PSScriptRoot\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

#TODO Items/Params implementation
$prefix = $global:Configuration.sslCerts.prefix
$password = $global:Configuration.sslCerts.password
$exportPath = Get-Location

ExportCert -RootCertName "SitecoreRootCert_$prefix" -ExportPath $exportPath -Password $password