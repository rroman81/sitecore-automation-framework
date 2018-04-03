Import-Module "$PSScriptRoot\..\..\Common\Run-Pipelines.psm1" -Force
$ErrorActionPreference = "Stop"

function CheckXP0 {
    $isXPO = $true
   
    if($global:Configuration.hosting -ne "OnPrem"){
        $isXPO = $false
    }
    if($global:Configuration.sitecoreMode -ne "XP"){
        $isXPO = $false
    }
    if($global:Configuration.serverRole -ne "AllInOne"){
        $isXPO = $false
    }

    if(!$isXPO){
        throw "SAF supports only uninstall of XP0 (AllInOne) instances..."
    }
}

function StartUninstall {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )
    
    CheckXP0
    $pipeline = "uninstallSitecore"

    if ($PSBoundParameters["Force"]) {
        RunSteps -Pipeline $pipeline -Force
    }
    else {
        RunSteps -Pipeline $pipeline
    }
}

Export-ModuleMember -Function "StartUninstall"