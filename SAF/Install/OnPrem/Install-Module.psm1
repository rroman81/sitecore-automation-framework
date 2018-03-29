Import-Module "$PSScriptRoot\..\..\Common\Run-Pipelines.psm1" -Force
Import-Module "$PSScriptRoot\..\..\Common\WebAdministration-Module.psm1" -Force
$ErrorActionPreference = "Stop"

function ImportSIF {
    Write-Output "Import Sitecore Installation Framework (SIF) started..."

    EnableIISAdministration
    
    $repositoryUrl = "https://sitecore.myget.org/F/sc-powershell/api/v2"
    $repositoryName = "SitecoreGallery"

    # Check to see whether that location is registered already
    $existing = Get-PSRepository -Name $repositoryName -ErrorAction Ignore

    # If not, register it
    if ($existing -eq $null) {
        Register-PSRepository -Name $repositoryName -SourceLocation $repositoryUrl -InstallationPolicy Trusted 
    }

    # Ensure Trusted, so that users are not prompted before installing modules from that source.
    Set-PSRepository -Name $repositoryName -InstallationPolicy Trusted

    if (Get-Module "SitecoreInstallFramework" -ListAvailable) {
        Update-Module "SitecoreInstallFramework"
    }
    else {
        Install-Module "SitecoreInstallFramework"
    }

    if (!(Get-Module "SitecoreInstallFramework")) {
        Import-Module "SitecoreInstallFramework"
    }

    Write-Output "Import Sitecore Installation Framework (SIF) done."
}

function ResolvePipeline {
    if ($global:Configuration.sitecoreMode -ne $null) {
        return "install$($global:Configuration.hosting)$($global:Configuration.serverRole)-$($global:Configuration.sitecoreMode)"
    }
    else {
        return "install$($global:Configuration.hosting)$($global:Configuration.serverRole)"
    }
}

function StartInstall {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )
    
    $pipeline = ResolvePipeline

    if ($PSBoundParameters["Force"]) {
        RunSteps -Pipeline $pipeline -Force
    }
    else {
        RunSteps -Pipeline $pipeline
    }
}

Export-ModuleMember -Function "StartInstall"
Export-ModuleMember -Function "ImportSIF"


