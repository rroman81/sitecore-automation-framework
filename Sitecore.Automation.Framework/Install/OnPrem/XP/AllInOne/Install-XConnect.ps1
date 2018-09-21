. "$PSScriptRoot\..\..\..\InstallParams.ps1"
Import-Module "$PSScriptRoot\..\..\..\..\SQL\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\Common\SSL\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Install xConnect started..."

$prefix = $global:Configuration.prefix
$clientCert = BuildClientCertName -Prefix $prefix
$xConnectHostName = $global:Configuration.xConnect.hostName
$serverCert = BuildServerCertName -Prefix $prefix
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlUser =  $global:Configuration.sql.adminUsername
$sqlAdminPassword =  $global:Configuration.sql.adminPassword
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$installDir = $global:Configuration.xConnect.installDir
$solrServiceURL = $global:Configuration.search.solr.serviceURL
$package = Get-ChildItem -Path "$SAFInstallPackageDir\*" -Include *xconnect.scwdp.zip*

$dbs = @("MarketingAutomation", "Messaging", "Processing.Pools", "ReferenceData", "Xdb.Collection.Shard0", "Xdb.Collection.Shard1", "Xdb.Collection.ShardMapManager")
DeleteDatabases -SqlServer $sqlServer -Prefix $prefix -Databases $dbs -Username $sqlUser -Password $sqlAdminPassword
DeleteLogin -SqlServer $sqlServer -SqlLogin "$($prefix)_collectionuser" -Username $sqlUser -Password $sqlAdminPassword

$xconnectParams = @{
    Path                           = "$SAFInstallPackageDir\xconnect-xp0.json"
    Package                        = $package.FullName
    LicenseFile                    = $license
    Sitename                       = $xConnectHostName
    SSLCert                        = $serverCert
    XConnectCert                   = $clientCert
    SqlDbPrefix                    = $prefix
    SqlServer                      = $sqlServer
    SqlAdminUser                   = $sqlUser
    SqlAdminPassword               = $sqlAdminPassword
    SqlCollectionUser              = "$($prefix)_collectionuser"
    SqlCollectionPassword          = $sqlSitecorePassword
    SqlProcessingPoolsUser         = "$($prefix)_processingpoolsuser"
    SqlProcessingPoolsPassword     = $sqlSitecorePassword
    SqlReferenceDataUser           = "$($prefix)_referencedatauser"
    SqlReferenceDataPassword       = $sqlSitecorePassword
    SqlMarketingAutomationUser     = "$($prefix)_marketingautomationuser"
    SqlMarketingAutomationPassword = $sqlSitecorePassword
    SqlMessagingUser               = "$($prefix)_messaginguser"
    SqlMessagingPassword           = $sqlSitecorePassword
    SolrCorePrefix                 = $prefix
    SolrURL                        = $solrServiceURL
    InstallDirectory               = $installDir
}
Install-SitecoreConfiguration @xconnectParams

Write-Output "Install xConnect done."