Import-Module "$PSScriptRoot\..\..\..\..\SQL\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlUserPassword = $global:Configuration.sql.adminPassword
$solrUrl = $global:Configuration.search.solr.serviceUrl
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *cd.scwdp.zip*

$count = 1

foreach ($cm in $global:Configuration.sitecore) {
    $siteName = $cm.hostName
    $installDir = $cm.installDir

    Write-Output "Testing installation of Sitecore CD$count..."
    if (Test-Uri -Uri "https://$siteName") {
        Write-Output "Sitecore CD$count has been installed before. Going forward..."
    }
    else {
        Write-Output "Install Sitecore CD$count started..."

        $sitecoreParams = @{
            Path              = "$sourcePackageDirectory\sitecore-XM1-cd.json"
            Package           = $package.FullName
            LicenseFile       = $license
            SqlDbPrefix       = $prefix
            SqlServer         = $sqlServer
            SqlCorePassword   = $sqlUserPassword
            SqlWebPassword    = $sqlUserPassword
            SqlFormsPassword  = $sqlUserPassword
            SolrCorePrefix    = $prefix
            SolrUrl           = $solrUrl
            Sitename          = $siteName
            InstallDirectory  = $installDir
        }

        Install-SitecoreConfiguration @sitecoreParams

        Write-Output "Install Sitecore CD$count done."
    }

    $count = $count + 1
}