$ErrorActionPreference = "Stop"

Write-Output "Importing SSL Certificates started..."

$password = $global:Configuration.ssl.importCertPassword
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

$dir = Get-Location

$pfxRootCert = "$dir\SitecoreRootSSLCertificate.pfx"
Import-PfxCertificate -FilePath $pfxRootCert -CertStoreLocation "Cert:\LocalMachine\Root" -Password $securePassword -Exportable | Out-Null

$pfxCert = "$dir\SitecoreSSLCertificates.pfx"
Import-PfxCertificate -FilePath $pfxCert -CertStoreLocation "Cert:\LocalMachine\My" -Password $securePassword -Exportable | Out-Null

Write-Output "Importing SSL Certificates done."