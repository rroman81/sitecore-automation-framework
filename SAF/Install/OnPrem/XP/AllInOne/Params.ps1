$SAFInstallPackageDir = "$PSScriptRoot\..\..\..\..\temp\package"
$SolrServiceDir = "$($global:Configuration.search.solr.installDir)\solr-$($global:Configuration.search.solr.version)"
$SolrServiceUrl = "https://$($global:Configuration.search.solr.hostName):$($global:Configuration.search.solr.port)/solr"