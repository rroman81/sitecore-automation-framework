Import-Module "$PSScriptRoot\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

#TODO Items/Params implementation
$prefix = $global:Configuration.sslCerts.prefix
$hostNames = $global:Configuration.sslCerts.hostNames

foreach ($hostName in $hostNames) {
    GenerateCert -CertName $hostName  -RootCertName "SitecoreRootCert_$prefix"
}


