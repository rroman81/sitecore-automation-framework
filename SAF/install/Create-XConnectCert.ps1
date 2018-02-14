$ErrorActionPreference = "Stop"

Write-Output "Creating xConnect certificate started..."

$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$certName = $global:Items.XConnectCertName

$certParams = @{
    Path            = "$sourcePackageDirectory\xconnect-createcert.json"
    CertificateName = "$certName"
}
Install-SitecoreConfiguration @certParams

Write-Output "Creating xConnect certificate done."