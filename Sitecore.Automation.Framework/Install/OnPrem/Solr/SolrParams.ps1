$SolrServiceDir = ""
$SolrServiceURL = ""

if([string]::IsNullOrEmpty($global:Configuration.solr.serviceURL)) {
    $SolrServiceDir = "$($global:Configuration.solr.install.installDir)\solr-$($global:Configuration.solr.install.version)"
    $SolrServiceURL = "https://$($global:Configuration.solr.install.hostName):$($global:Configuration.solr.install.port)/solr"
}
else {
    $SolrServiceURL = $global:Configuration.solr.serviceURL
}
