Import-Module "$PSScriptRoot\..\common\Run-Pipelines.psm1"
$ErrorActionPreference = "Stop"

function ResolvePipeline {
    return "install$($global:Configuration.hosting)$($global:Configuration.serverRole)"
}

function LoadItems {
    [CmdletBinding()]
    Param
    (
        [string]$Pipeline
    )

    if($Pipeline -eq "installOnPremAllInOne") {
        $installPackageDir = "$PSScriptRoot\..\temp\package"
        $global:Items.Add("SAFInstallPackageDir", $installPackageDir)

        $solrServiceRoot = "$($global:Configuration.search.solr.installDir)\solr-$($global:Configuration.search.solr.version)"
        $global:Items.Add("SolrServiceDir", $solrServiceRoot)

        $global:Items.Add("SolrServiceUrl", "https://$($global:Configuration.search.solr.hostName):$($global:Configuration.search.solr.port)/solr")

        $certName = "$($global:Configuration.prefix).xconnect_client"
        $global:Items.Add("XConnectCertName", $certName)
    }
}

function StartInstall {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )
    
    $pipeline = ResolvePipeline
    LoadItems -Pipeline $pipeline

    if ($PSBoundParameters["Force"]) {
        RunSteps -Pipeline $pipeline -Force
    }
    else {
        RunSteps -Pipeline $pipeline
    }
}

Export-ModuleMember -Function "StartInstall"

