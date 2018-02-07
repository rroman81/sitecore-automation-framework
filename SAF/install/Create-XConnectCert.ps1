$ErrorActionPreference = "Stop"

Write-Host "Creating xConnect certificate started..."

$prefix = $global:Configuration.prefix
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$certName = "$prefix.xconnect_client"
$global:Items.Add("XConnectCertName", $certName)

$certParams = @{
    Path            = "$sourcePackageDirectory\xconnect-createcert.json"
    CertificateName = "$certName"
}
Install-SitecoreConfiguration @certParams

Write-Host "Creating xConnect certificate done."