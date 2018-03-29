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
    CheckXP0
    $pipeline = "uninstallSitecore"
    RunSteps -Pipeline $pipeline
}

Export-ModuleMember -Function "StartUninstall"