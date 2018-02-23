Import-Module "$PSScriptRoot\..\common\Utils-Module.psm1"
$ErrorActionPreference = "Stop"

$Version = $global:Configuration.search.solr.version
$InstallDir = $global:Configuration.search.solr.installDir
$HostName = $global:Configuration.search.solr.hostName
$Port = $global:Configuration.search.solr.port
$ServiceDir = $global:Items.SolrServiceDir
$ServiceName = $global:Configuration.search.solr.serviceName
$ServiceDisplayName = $global:Configuration.search.solr.serviceDisplayName
$ServiceDesctiption = $global:Configuration.search.solr.serviceDescription

InstallSolr -Version $Version -InstallDir $InstallDir -HostName $HostName -Port $Port -ServiceDir $ServiceDir -ServiceName $ServiceName -ServiceDisplayName $ServiceDisplayName -ServiceDescription $ServiceDesctiption