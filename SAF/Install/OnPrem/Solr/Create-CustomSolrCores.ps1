. "$PSScriptRoot\..\..\InstallParams.ps1"
. "$PSScriptRoot\SolrParams.ps1"
$ErrorActionPreference = "Stop"

Write-Output "Add custom Solr cores started..."

if (($global:Configuration.solr.customCores -eq $null) -or ($global:Configuration.solr.customCores.Count -lt 1)) {
    Write-Warning "No custom Solr cores found."
}
else {
    $prefix = $global:Configuration.prefix
    $configPath = "$PSScriptRoot\custom-solr.json"
    $solrService = $global:Configuration.solr.install.serviceName

    foreach ($index in $global:Configuration.solr.customCores) {
        $solrParams = @{
            Path        = $configPath
            SolrUrl     = $SolrServiceURL
            SolrRoot    = $SolrServiceDir
            SolrService = $solrService
            CorePrefix  = $prefix  
            CoreName    = $index.name
        }
        Install-SitecoreConfiguration @solrParams
    }
}

Write-Output "Add custom Solr cores done."