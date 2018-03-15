Import-Module "$PSScriptRoot\..\..\..\..\SQL\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$siteName = $global:Configuration.reporting.hostName
$sslCert = $global:Configuration.reporting.sslCert
if ([string]::IsNullOrEmpty($sslCert)) {
    $sslCert = $siteName
}
$installDir = $global:Configuration.reporting.installDir
$serviceApiKey = $global:Configuration.reporting.serviceApiKey
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *rep.scwdp.zip*

Write-Output "Install Sitecore Reporting started..."

$sitecoreParams = @{
    Path                   = "$sourcePackageDirectory\sitecore-XP1-rep.json"
    Package                = $package.FullName
    LicenseFile            = $license
    Sitename               = $siteName
    SSLCert                = $sslCert
    SqlDbPrefix            = $prefix
    SqlCoreUser            = "$($prefix)_coreuser"
    SqlCorePassword        = $sqlSitecorePassword
    SqlMasterUser          = "$($prefix)_masteruser"
    SqlMasterPassword      = $sqlSitecorePassword
    SqlWebUser             = "$($prefix)_webuser"
    SqlWebPassword         = $sqlSitecorePassword
    SqlReportingUser       = "$($prefix)_reportinguser"
    SqlReportingPassword   = $sqlSitecorePassword
    SqlServer              = $sqlServer
    ReportingServiceApiKey = $serviceApiKey 
    InstallDirectory       = $installDir
}

Install-SitecoreConfiguration @sitecoreParams

Write-Output "Install Sitecore Reporting done."