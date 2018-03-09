$ErrorActionPreference = "Stop"

Write-Output "Ensure xConnect SSL certificate started..."

if ([string]::IsNullOrEmpty($global:Configuration.xConnect.sslCert)) {
    
    Write-Warning "xConnect SSL Certificate is not provided. SAF is generating certificate..." 
    
    $sourcePackageDirectory = $global:Items.SAFInstallPackageDir
    $certName = $global:Items.XConnectCertName

    $certParams = @{
        Path            = "$sourcePackageDirectory\xconnect-createcert.json"
        CertificateName = "$certName"
    }
    
    Install-SitecoreConfiguration @certParams
}

Write-Output "Ensure xConnect SSL certificate done."