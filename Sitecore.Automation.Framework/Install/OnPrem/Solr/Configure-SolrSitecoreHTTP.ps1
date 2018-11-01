. "$PSScriptRoot\SolrParams.ps1"
$ErrorActionPreference = "Stop"

Write-Output "Add Sitecore Solr cores started..."

$prefix = $global:Configuration.prefix

$solrParams = @{
    Path        = "$PSScriptRoot\sitecore-solrHTTP.json"
    SolrUrl     = $SolrServiceURL
    CorePrefix  = $prefix
}
Install-SitecoreConfiguration @solrParams

Write-Output "Add Sitecore Solr cores done."