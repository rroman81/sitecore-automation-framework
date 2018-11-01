Import-Module "$PSScriptRoot\..\..\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$solrService = $global:Configuration.solr.install.serviceName
$services = @($solrService)
DeleteServices -Services $services