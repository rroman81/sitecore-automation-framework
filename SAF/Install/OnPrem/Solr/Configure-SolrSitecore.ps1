. "$PSScriptRoot\..\..\InstallParams.ps1"
. "$PSScriptRoot\SolrParams.ps1"
$ErrorActionPreference = "Stop"

Write-Output "Add Sitecore Solr cores started..."

$prefix = $global:Configuration.prefix
$solrService = $global:Configuration.search.solr.serviceName

$solrParams = @{
    Path        = "$SAFInstallPackageDir\sitecore-solr.json"
    SolrUrl     = $SolrServiceUrl
    SolrRoot    = $SolrServiceDir
    SolrService = $solrService
    CorePrefix  = $prefix
}
Install-SitecoreConfiguration @solrParams

Write-Output "Add Sitecore Solr cores done."