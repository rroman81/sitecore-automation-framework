$ErrorActionPreference = "Stop"

Write-Host "Creating xConnect certificate started..."

$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$certName = $global:Items.XConnectCertName

$certParams = @{
    Path            = "$sourcePackageDirectory\xconnect-createcert.json"
    CertificateName = "$certName"
}
Install-SitecoreConfiguration @certParams

Write-Host "Creating xConnect certificate done."