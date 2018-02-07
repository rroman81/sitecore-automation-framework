Import-Module "$PSScriptRoot\..\common\Run-Pipelines.psm1" -Force
$ErrorActionPreference = "Stop"

function ResolvePipeline {
    return "install$($global:Configuration.hosting)$($global:Configuration.serverRole)"
}

function StartInstall {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )
    
    $pipeline = ResolvePipeline

    if($PSBoundParameters["Force"]) {
        RunSteps -Pipeline $pipeline -Force
    } else{
        RunSteps -Pipeline $pipeline
    }
}

Export-ModuleMember -Function "StartInstall"

