Import-Module "$PSScriptRoot\..\..\..\Common\Utils-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\Common\SSL\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$hostName = $global:Configuration.search.solr.hostName
$serverCert = BuildServerCertName -Prefix $prefix -Hostname $hostName
$port = $global:Configuration.search.solr.port
$version = $global:Configuration.search.solr.version
$installDir = $global:Configuration.search.solr.installDir
$serviceDir = $global:Items.SolrServiceDir
$serviceName = $global:Configuration.search.solr.serviceName
$serviceDisplayName = $global:Configuration.search.solr.serviceDisplayName
$serviceDesctiption = $global:Configuration.search.solr.serviceDescription

InstallSolr -Version $version -InstallDir $installDir -HostName $hostName -Port $port -SSLCert $serverCert -ServiceDir $serviceDir -ServiceName $serviceName -ServiceDisplayName $serviceDisplayName -ServiceDescription $serviceDesctiption