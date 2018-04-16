Import-Module "$PSScriptRoot\..\..\Common\Run-Pipelines.psm1" -Force
$ErrorActionPreference = "Stop"

function IsXP0 {
    if($global:Configuration.hosting -ne "OnPrem") {
        return $false
    }
    if($global:Configuration.sitecoreMode -ne "XP") {
        return $false
    }
    if($global:Configuration.serverRole -ne "AllInOne") {
        return $false
    }

    return $true
}

function IsSolrRunningAsLocalService {
    if([string]::IsNullOrEmpty($global:Configuration.solr.serviceURL)) {
        return $true
    }
    return $false
}

function StartUninstallSitecore {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )
    
    if(!(IsXP0)) {
        throw "SAF supports only uninstall of XP0 (AllInOne) instances..."
    }

    $pipeline = "uninstallSitecore"

    if ($Force.IsPresent) {
        RunSteps -Pipeline $pipeline -Force
    }
    else {
        RunSteps -Pipeline $pipeline
    }
}

function StartUninstallSolr {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )
    
    if(!(IsSolrRunningAsLocalService)) {
        throw "SAF supports only uninstall of Solr running as local service..."
    }

    $pipeline = "uninstallSolr"

    if ($Force.IsPresent) {
        RunSteps -Pipeline $pipeline -Force
    }
    else {
        RunSteps -Pipeline $pipeline
    }
}

Export-ModuleMember -Function "StartUninstallSitecore"
Export-ModuleMember -Function "StartUninstallSolr"