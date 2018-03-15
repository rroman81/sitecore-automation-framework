$ErrorActionPreference = "Stop"

Write-Output "Add xConnect Solr cores started..."

$prefix = $global:Configuration.prefix
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$solrUrl = $global:Items.SolrServiceUrl
$solrRoot = $global:Items.SolrServiceDir
$solrService = $global:Configuration.search.solr.serviceName

$solrParams = @{
    Path        = "$sourcePackageDirectory\xconnect-solr.json"
    SolrUrl     = $solrUrl
    SolrRoot    = $solrRoot
    SolrService = $solrService
    CorePrefix  = $prefix
}
Install-SitecoreConfiguration @solrParams

Write-Output "Add xConnect Solr cores done."