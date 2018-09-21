. "$PSScriptRoot\SolrParams.ps1"
$ErrorActionPreference = "Stop"

Write-Output "Add xConnect Solr cores started..."

$prefix = $global:Configuration.prefix

$solrParams = @{
    Path        = "$PSScriptRoot\xconnect-solrHTTP.json"
    SolrUrl     = $SolrServiceURL
    CorePrefix  = $prefix
}
Install-SitecoreConfiguration @solrParams

Write-Output "Add xConnect Solr cores done."