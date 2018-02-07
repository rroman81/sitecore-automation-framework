Import-Module "$PSScriptRoot\..\sql\SQL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Host "Install Sitecore started..."

$prefix = $global:Configuration.prefix
$license = $global:Configuration.license
$siteName = $global:Configuration.sitecore.hostName
$xConnectCollectionService = $global:Configuration.xConnect.hostName
$cert = $global:Items.XConnectCertName
$sqlServer = $global:Configuration.sql.serverName
$sqlUser =  $global:Configuration.sql.username
$sqlUserPassword =  $global:Configuration.sql.password
$installDir = $global:Configuration.sitecore.installDir
$solrUrl = $global:Items.SolrServiceUrl
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *single.scwdp.zip*

CleanInstalledSitecoreDbs -SqlServer $sqlServer -Prefix $prefix

$sitecoreParams = @{
    Path                      = "$sourcePackageDirectory\sitecore-XP0.json"
    Package                   = $package.FullName
    LicenseFile               = $license
    SqlDbPrefix               = $prefix
    SqlServer                 = $sqlServer
    SqlAdminUser              = $sqlUser
    SqlAdminPassword          = $sqlUserPassword
    SolrCorePrefix            = $prefix
    SolrUrl                   = $solrUrl
    XConnectCert              = $cert
    Sitename                  = $siteName
    XConnectCollectionService = "https://$xConnectCollectionService"
    InstallDirectory          = $installDir
}
Install-SitecoreConfiguration @sitecoreParams

Write-Host "Install Sitecore done."