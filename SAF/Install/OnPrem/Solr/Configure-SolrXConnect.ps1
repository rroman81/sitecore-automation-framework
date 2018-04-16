. "$PSScriptRoot\..\..\InstallParams.ps1"
. "$PSScriptRoot\SolrParams.ps1"
$ErrorActionPreference = "Stop"

Write-Output "Add xConnect Solr cores started..."

$prefix = $global:Configuration.prefix
$solrService = $global:Configuration.solr.install.serviceName

$solrParams = @{
    Path        = "$SAFInstallPackageDir\xconnect-solr.json"
    SolrUrl     = $SolrServiceURL
    SolrRoot    = $SolrServiceDir
    SolrService = $solrService
    CorePrefix  = $prefix
}
Install-SitecoreConfiguration @solrParams

Write-Output "Add xConnect Solr cores done."