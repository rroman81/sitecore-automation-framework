$ErrorActionPreference = "Stop"

Write-Output "Creating custom Solr cores started..."

if (($global:Configuration.search.solr.customCores -eq $null) -or ($global:Configuration.search.solr.customCores -lt 1)) {
    Write-Warning "No custom Solr cores found."
}
else {
    $prefix = $global:Configuration.prefix
    $configPath = "$PSScriptRoot\custom-solr.json"
    $solrUrl = $global:Items.SolrServiceUrl
    $solrRoot = $global:Items.SolrServiceDir
    $solrService = $global:Configuration.search.solr.serviceName

    foreach ($index in $global:Configuration.search.solr.customCores) {
        $solrParams = @{
            Path        = $configPath
            SolrUrl     = $solrUrl
            SolrRoot    = $solrRoot
            SolrService = $solrService
            CorePrefix  = $prefix  
            CoreName    = $index.name
        }
        Install-SitecoreConfiguration @solrParams
    }
}

Write-Output "Creating custom Solr cores done."