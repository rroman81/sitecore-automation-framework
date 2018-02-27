$ErrorActionPreference = "Stop"

Write-Output "Add Sitecore Solr cores started..."

$prefix = $global:Configuration.prefix
$solrService = $global:Configuration.search.solr.serviceName
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$solrUrl = $global:Items.SolrServiceUrl
$solrRoot = $global:Items.SolrServiceDir

$solrParams = @{
    Path        = "$sourcePackageDirectory\sitecore-solr.json"
    SolrUrl     = $solrUrl
    SolrRoot    = $solrRoot
    SolrService = $solrService
    CorePrefix  = $prefix
}
Install-SitecoreConfiguration @solrParams

Write-Output "Add Sitecore Solr cores done."