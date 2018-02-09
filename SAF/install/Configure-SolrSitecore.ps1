$ErrorActionPreference = "Stop"

Write-Host "Configuration of Solr for Sitecore started..."

$prefix = $global:Configuration.prefix
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$solrUrl = $global:Items.SolrServiceUrl
$solrRoot = $global:Items.SolrServiceDir
Write-Warning $solrRoot
$solrService = $global:Configuration.search.solr.serviceName

$solrParams = @{
    Path        = "$sourcePackageDirectory\sitecore-solr.json"
    SolrUrl     = $solrUrl
    SolrRoot    = $solrRoot
    SolrService = $solrService
    CorePrefix  = $prefix
}
Install-SitecoreConfiguration @solrParams

Write-Host "Configuration of Solr for Sitecore done."