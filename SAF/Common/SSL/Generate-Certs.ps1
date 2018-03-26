Import-Module "$PSScriptRoot\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix

foreach ($sslCert in $global:Configuration.sslCerts) {
    $hostNames = $sslCert.hostNames
    GenerateServerCert -Prefix $prefix -Hostnames $hostNames
}

GenerateClientCert -Prefix $prefix


