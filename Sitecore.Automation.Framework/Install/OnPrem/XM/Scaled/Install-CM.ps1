. "$PSScriptRoot\..\..\..\InstallParams.ps1"
Import-Module "$PSScriptRoot\..\..\..\..\SQL\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\Common\SSL\SSL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\Common\WebAdministration-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlUser = $global:Configuration.sql.adminUsername
$sqlAdminPassword = $global:Configuration.sql.adminPassword
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$solrURL = $global:Configuration.search.solr.serviceURL
$package = Get-ChildItem -Path "$SAFInstallPackageDir\*" -Include *cm.scwdp.zip*

$count = 1

foreach ($cm in $global:Configuration.sitecore) {
    $hostNames = $cm.hostNames
    $siteName = $hostNames[0]
    $installDir = $cm.installDir
    $sslCert = $cm.sslCert
    if ([string]::IsNullOrEmpty($sslCert)) {
        $sslCert = BuildServerCertName -Prefix $prefix
    }

    Write-Output "Testing installation of Sitecore CM$count..."
    if (TestURI -Uri "https://$siteName") {
        Write-Output "Sitecore CM$count has been installed before. Going forward..."
    }
    else {
        Write-Output "Install Sitecore CM$count started..."

        $dbs = @("Core", "Master", "Web", "ExperienceForms")
        DeleteDatabases -SqlServer $sqlServer -Prefix $prefix -Databases $dbs -Username $sqlUser -Password $sqlAdminPassword

        $sitecoreParams = @{
            Path              = "$SAFInstallPackageDir\sitecore-XM1-cm.json"
            Package           = $package.FullName
            LicenseFile       = $license
            SqlDbPrefix       = $prefix
            SqlServer         = $sqlServer
            SqlAdminUser      = $sqlUser
            SqlAdminPassword  = $sqlAdminPassword
            SqlCoreUser       = "$($prefix)_coreuser"
            SqlCorePassword   = $sqlSitecorePassword
            SqlMasterUser     = "$($prefix)_masteruser"
            SqlMasterPassword = $sqlSitecorePassword
            SqlWebUser        = "$($prefix)_webuser"
            SqlWebPassword    = $sqlSitecorePassword
            SqlFormsUser      = "$($prefix)_formsuser"
            SqlFormsPassword  = $sqlSitecorePassword
            SolrCorePrefix    = $prefix
            SolrUrl           = $solrURL
            Sitename          = $siteName
            SSLCert           = $sslCert
            InstallDirectory  = $installDir
        }
        Install-SitecoreConfiguration @sitecoreParams
        AddWebBindings -SiteName $siteName -HostNames $hostNames -SSLCert $sslCert -Secure
        Write-Output "Install Sitecore CM$count done."
    }

    $count = $count + 1


}