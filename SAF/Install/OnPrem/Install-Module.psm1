Import-Module "$PSScriptRoot\..\..\Common\Run-Pipelines.psm1" -Force
Import-Module "$PSScriptRoot\..\..\Common\WebAdministration-Module.psm1" -Force
$ErrorActionPreference = "Stop"

function ImportSIF {
    [CmdletBinding()]
    Param
    (
        [string]$RepositoryURL,
        [string]$Version
    )
    
    Write-Output "Import Sitecore Installation Framework (SIF) started..."

    EnableIISAdministration
    
    $repositoryName = "SitecoreGallery"

    # Check to see whether that location is registered already
    $existing = Get-PSRepository -Name $repositoryName -ErrorAction Ignore

    # If not, register it
    if ($existing -eq $null) {
        Write-Output "Registering $repositoryName '$RepositoryURL'..."
        Register-PSRepository -Name $repositoryName -SourceLocation $RepositoryURL -InstallationPolicy Trusted
    }
    else {
        Write-Warning "$repositoryName '$RepositoryURL' is already registered."
    }

    # Ensure Trusted, so that users are not prompted before installing modules from that source.
    Set-PSRepository -Name $repositoryName -InstallationPolicy Trusted

    if (Get-Module "SitecoreInstallFramework" -ListAvailable) {
        Write-Warning "SitecoreInstallFramework is installed. Updating..."
        Update-Module "SitecoreInstallFramework"
    }
    else {
        Write-Output "Installing SitecoreInstallFramework..."
        Install-Module "SitecoreInstallFramework"
    }

    Import-Module "SitecoreInstallFramework" -RequiredVersion $Version
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


