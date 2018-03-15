Import-Module "$PSScriptRoot\..\..\..\..\SQL\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlUser = $global:Configuration.sql.adminUsername
$sqlAdminPassword = $global:Configuration.sql.adminPassword
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$siteName = $global:Configuration.referenceData.hostName
$sslCert = $global:Configuration.referenceData.sslCert
if ([string]::IsNullOrEmpty($sslCert)) {
    $sslCert = $siteName
}
$xConnectSslCert = $global:Configuration.xConnect.sslCert
if ([string]::IsNullOrEmpty($xConnectSslCert)) {
    $xConnectSslCert = $siteName
}
$installDir = $global:Configuration.referenceData.installDir
$environment = $global:Configuration.xConnect.environment
$logLevel = $global:Configuration.xConnect.logLevel
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *referencedata.scwdp.zip*

Write-Output "Install xDB Reference Data started..."

$dbs = @("ReferenceData")
DeleteDatabases -SqlServer $sqlServer -Prefix $prefix -Databases $dbs -Username $sqlUser -Password $sqlAdminPassword

$sitecoreParams = @{
    Path                           = "$sourcePackageDirectory\xconnect-xp1-ReferenceData.json"
    Package                        = $package.FullName
    LicenseFile                    = $license
    Sitename                       = $siteName
    XConnectCert                   = $xConnectSslCert
    SSLCert                        = $sslCert
    SqlDbPrefix                    = $prefix
    SqlAdminUser                   = $sqlUser
    SqlAdminPassword               = $sqlAdminPassword
    SqlReferenceDataUser           = "$($prefix)_referencedatauser"
    SqlReferenceDataPassword       = $sqlSitecorePassword
    SqlServer                      = $sqlServer
    XConnectEnvironment            = $environment
    XConnectLogLevel               = $logLevel
    InstallDirectory               = $installDir
}

Install-SitecoreConfiguration @sitecoreParams

Write-Output "Install xDB Reference Data done."