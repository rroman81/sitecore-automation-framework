. "$PSScriptRoot\..\..\..\..\InstallParams.ps1"
Import-Module "$PSScriptRoot\..\..\..\..\..\Common\SSL\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$siteName = $global:Configuration.xDB.automationReportingHostName
$sslCert = $global:Configuration.xDB.sslCert
if ([string]::IsNullOrEmpty($sslCert)) {
    $sslCert = BuildServerCertName -Prefix $prefix
}
$xConnectSslCert = $global:Configuration.xConnect.sslCert
if ([string]::IsNullOrEmpty($xConnectSslCert)) {
    $xConnectSslCert = BuildClientCertName -Prefix $prefix
}
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$installDir = $global:Configuration.xDB.installDir
$environment = $global:Configuration.xConnect.environment
$logLevel = $global:Configuration.xConnect.logLevel
$package = Get-ChildItem -Path "$SAFInstallPackageDir\*" -Include *marketingautomationreporting.scwdp.zip*

Write-Output "Install xDB Automation Reporting started..."

$sitecoreParams = @{
    Path                           = "$SAFInstallPackageDir\xconnect-xp1-MarketingAutomationReporting.json"
    Package                        = $package.FullName
    LicenseFile                    = $license
    Sitename                       = $siteName
    XConnectCert                   = $xConnectSslCert
    SSLCert                        = $sslCert
    SqlDbPrefix                    = $prefix
    SqlReferenceDataUser           = "$($prefix)_referencedatauser"
    SqlReferenceDataPassword       = $sqlSitecorePassword
    SqlMarketingAutomationUser     = "$($prefix)_marketingautomationuser"
    SqlMarketingAutomationPassword = $sqlSitecorePassword
    SqlServer                      = $sqlServer
    XConnectEnvironment            = $environment
    XConnectLogLevel               = $logLevel
    InstallDirectory               = $installDir
}
Install-SitecoreConfiguration @sitecoreParams

Write-Output "Install xDB Automation Reporting done."