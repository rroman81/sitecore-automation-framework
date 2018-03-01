Import-Module "$PSScriptRoot\..\..\..\..\SQL\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlUser = $global:Configuration.sql.adminUsername
$sqlUserPassword = $global:Configuration.sql.adminPassword
$solrUrl = $global:Configuration.search.solr.serviceUrl
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *cm.scwdp.zip*

$count = 1

foreach ($cm in $global:Configuration.sitecore) {
    $siteName = $cm.hostName
    $installDir = $cm.installDir

    Write-Output "Testing installation of Sitecore CM$count..."
    if (Test-Uri -Uri "https://$siteName") {
        Write-Output "Sitecore CM$count has been installed before. Going forward..."
    }
    else {
        Write-Output "Install Sitecore CM$count started..."

        CleanCMInstalledSitecoreDbs -SqlServer $sqlServer -Prefix $prefix

        $sitecoreParams = @{
            Path              = "$sourcePackageDirectory\sitecore-XM1-cm.json"
            Package           = $package.FullName
            LicenseFile       = $license
            SqlDbPrefix       = $prefix
            SqlServer         = $sqlServer
            SqlAdminUser      = $sqlUser
            SqlAdminPassword  = $sqlUserPassword
            SqlCorePassword   = $sqlUserPassword
            SqlMasterPassword = $sqlUserPassword
            SqlWebPassword    = $sqlUserPassword
            SqlFormsPassword  = $sqlUserPassword
            SolrCorePrefix    = $prefix
            SolrUrl           = $solrUrl
            Sitename          = $siteName
            InstallDirectory  = $installDir
        }

        Install-SitecoreConfiguration @sitecoreParams

        Write-Output "Install Sitecore CM$count done."
    }

    $count = $count + 1
}