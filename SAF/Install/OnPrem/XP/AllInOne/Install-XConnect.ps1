Import-Module "$PSScriptRoot\..\..\..\..\SQL\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Install xConnect started..."

$prefix = $global:Configuration.prefix
$license = $global:Configuration.license
$xConnectCollectionService = $global:Configuration.xConnect.hostName
$cert = $global:Items.XConnectCertName
$sqlServer = $global:Configuration.sql.serverName
$sqlUser =  $global:Configuration.sql.adminUsername
$sqlAdminPassword =  $global:Configuration.sql.adminPassword
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$installDir = $global:Configuration.xConnect.installDir
$solrUrl = $global:Items.SolrServiceUrl
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *xconnect.scwdp.zip*

CleanInstalledXConnectDbs -SqlServer $sqlServer -Prefix $prefix -Username $sqlUser -Password $sqlAdminPassword
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
    SqlAdminPassword               = $sqlAdminPassword
    SqlCollectionPassword          = $sqlSitecorePassword
    SqlProcessingPoolsPassword     = $sqlSitecorePassword
    SqlReferenceDataPassword       = $sqlSitecorePassword
    SqlMarketingAutomationPassword = $sqlSitecorePassword
    SqlMessagingPassword           = $sqlSitecorePassword
    SolrCorePrefix                 = $prefix
    SolrURL                        = $solrUrl
    InstallDirectory               = $installDir
}
Install-SitecoreConfiguration @xconnectParams

Write-Output "Install xConnect done."