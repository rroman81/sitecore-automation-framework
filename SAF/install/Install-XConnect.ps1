Import-Module "$PSScriptRoot\..\sql\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Install xConnect started..."

$prefix = $global:Configuration.prefix
$license = $global:Configuration.license
$xConnectCollectionService = $global:Configuration.xConnect.hostName
$cert = $global:Items.XConnectCertName
$sqlServer = $global:Configuration.sql.serverName
$sqlUser =  $global:Configuration.sql.username
$sqlUserPassword =  $global:Configuration.sql.password
$installDir = $global:Configuration.xConnect.installDir
$solrUrl = $global:Items.SolrServiceUrl
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *xconnect.scwdp.zip*

CleanInstalledXConnectDbs -SqlServer $sqlServer -Prefix $prefix
CleanInstalledXConnectServices -HostName $xConnectCollectionService

$xconnectParams = @{
    Path                           = "$sourcePackageDirectory\xconnect-xp0.json"
    Package                        = $package.FullName
    LicenseFile                    = $license
    Sitename                       = $xConnectCollectionService
    XConnectCert                   = $cert
    SqlDbPrefix                    = $prefix
    SqlServer                      = $sqlServer
    SqlAdminUser                   = $sqlUser
    SqlAdminPassword               = $sqlUserPassword
    SqlCollectionPassword          = $sqlUserPassword
    SqlProcessingPoolsPassword     = $sqlUserPassword
    SqlReferenceDataPassword       = $sqlUserPassword
    SqlMarketingAutomationPassword = $sqlUserPassword
    SqlMessagingPassword           = $sqlUserPassword
    SolrCorePrefix                 = $prefix
    SolrURL                        = $solrUrl
    InstallDirectory               = $installDir
}
Install-SitecoreConfiguration @xconnectParams

Write-Output "Install xConnect done."