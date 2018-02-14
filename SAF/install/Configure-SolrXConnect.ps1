$ErrorActionPreference = "Stop"

Write-Output "Configuration of Solr for xConnect started..."

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

Write-Output "Configuration of Solr for xConnect done."