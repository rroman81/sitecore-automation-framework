. "$PSScriptRoot\SolrParams.ps1"
Import-Module "$PSScriptRoot\..\..\..\Common\SSL\SSL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\Install\OnPrem\Solr\Solr-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$hostName = $global:Configuration.solr.install.hostName
$serverCert = BuildServerCertName -Prefix $prefix
$port = $global:Configuration.solr.install.port
$version = $global:Configuration.solr.install.version
$installDir = $global:Configuration.solr.install.installDir
$serviceName = $global:Configuration.solr.install.serviceName
$serviceDisplayName = $global:Configuration.solr.install.serviceDisplayName
$serviceDesctiption = $global:Configuration.solr.install.serviceDescription

InstallSolr -Version $version -InstallDir $installDir -HostName $hostName -Port $port -SSLCert $serverCert -ServiceDir $SolrServiceDir -ServiceName $serviceName -ServiceDisplayName $serviceDisplayName -ServiceDescription $serviceDesctiption