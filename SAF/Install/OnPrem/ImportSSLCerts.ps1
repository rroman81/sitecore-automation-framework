$ErrorActionPreference = "Stop"

Write-Output "Importing SSL Certificates started..."

$password = $global:Configuration.ssl.importCertPassword
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

$dir = Get-Location

$pfxRootCert = "$dir\SitecoreRootSSLCertificate_SAF.pfx"
Import-PfxCertificate -FilePath $pfxRootCert -CertStoreLocation "Cert:\LocalMachine\Root" -Password $securePassword -Exportable -Verbose

$pfxCert = "$dir\SitecoreSSLCertificates_SAF.pfx"
Import-PfxCertificate -FilePath $pfxCert -CertStoreLocation "Cert:\LocalMachine\My" -Password $securePassword -Exportable -Verbose

Write-Output "Importing SSL Certificates done."