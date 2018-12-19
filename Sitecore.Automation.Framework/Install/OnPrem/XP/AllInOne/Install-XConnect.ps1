. "$PSScriptRoot\..\..\..\InstallParams.ps1"
Import-Module "$PSScriptRoot\..\..\..\..\SQL\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\Common\SSL\SSL-Module.psm1" -Force
Import-Module BitsTransfer
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

if ($global:Configuration.XConnect.installPackage) {
    $package = $global:Configuration.XConnect.installPackage

    if ($package.StartsWith("http") -and $global:Configuration.SASToken) {
        $package += $global:Configuration.SASToken
        
        $destinationPath = "$SAFInstallPackageDir/$($global:Configuration.XConnect.installPackage.substring($global:Configuration.XConnect.installPackage.LastIndexOf('/')+1))"
        Write-Verbose "Downloading $package to $destinationPath"
        Start-BitsTransfer -Source $package -Destination $destinationPath 
    } else {
        $destinationPath = "$SAFInstallPackageDir/$($global:Configuration.XConnect.installPackage.substring($global:Configuration.XConnect.installPackage.LastIndexOf('\')+1))"
        Write-Verbose "Copying $package to $destinationPath"
        Copy-Item -Path $package -Destination $destinationPath
    }
}
  
$package = (Get-ChildItem -Path "$SAFInstallPackageDir\*" -Include *xconnect.scwdp.zip*).FullName


$dbs = @("MarketingAutomation", "Messaging", "Processing.Pools", "ReferenceData", "Xdb.Collection.Shard0", "Xdb.Collection.Shard1", "Xdb.Collection.ShardMapManager")
DeleteDatabases -SqlServer $sqlServer -Prefix $prefix -Databases $dbs -Username $sqlUser -Password $sqlAdminPassword
DeleteLogin -SqlServer $sqlServer -SqlLogin "$($prefix)_collectionuser" -Username $sqlUser -Password $sqlAdminPassword

$xconnectParams = @{
    Path                           = "$SAFInstallPackageDir\xconnect-xp0.json"
    Package                        = $package
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
Install-SitecoreConfiguration @xconnectParams -Verbose:$VerbosePreference

Write-Output "Install xConnect done."