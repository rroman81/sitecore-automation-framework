Import-Module "$PSScriptRoot\Common\Initialization-Module.psm1" -Force
Import-Module "$PSScriptRoot\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Set-ExecutionPolicy Bypass -Scope Process -Force

$global:Configuration = $null
$global:Pipelines = Get-Content -Raw -Path "$PSScriptRoot\common\Pipelines.json" | ConvertFrom-Json

function CheckSSLCertsPFX {
    $dir = Get-Location

    $pfxRootCert = "$dir\SitecoreRootSSLCertificate_SAF.pfx"
    if (!(Test-Path $pfxRootCert)) {
        throw "Please, provide 'SitecoreRootSSLCertificate_SAF.pfx' file."
    }

    $pfxCert = "$dir\SitecoreSSLCertificates_SAF.pfx"
    if (!(Test-Path $pfxCert)) {
        throw "Please, provide 'SitecoreSSLCertificates_SAF.pfx' file."
    }
}

function LoadCofigurations {
    [CmdletBinding()]
    Param
    (
        [string]$ConfigName
    )

    $dir = Get-Location
    $configFile = "$dir\$ConfigName.json"

    if (!(Test-Path $configFile)) {
        throw "Please, provide '$ConfigName.json' file."
    }

    $global:Configuration = Get-Content -Raw -Path $configFile | ConvertFrom-Json
}

function Initialize {

    Write-Output "`n`n------------------------------------------------------"
    Write-Output "--- Welcome to Sitecore Automation Framework (SAF) ---"
    Write-Output "------------------------------------------------------`n`n"
    
    ## Verify elevated
    ## https://superuser.com/questions/749243/detect-if-powershell-is-running-as-administrator
    $elevated = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
    if ($elevated -eq $false) {
        throw "In order to use SAF, please run this script elevated."
    }

    Write-Warning "SAF initialization will start after 3 seconds..."
    Start-Sleep -s 3

    ConfigurePSGallery
    ConfigureChoco
    RefreshEnvironment

    Write-Warning "SAF initialization is done."
}

function Install-Sitecore {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )

    Initialize
    LoadCofigurations -ConfigName "InstallConfiguration"
    CheckSSLCertsPFX

    Import-Module "$PSScriptRoot\Install\OnPrem\Install-Module.psm1" -Force

    if ($PSBoundParameters["Force"]) {
        StartInstall -Force
    }
    else {
        StartInstall
    }
}

function Uninstall-Sitecore {
    Initialize
    LoadCofigurations -ConfigName "InstallConfiguration"

    Import-Module "$PSScriptRoot\Install\OnPrem\Uninstall-Module.psm1" -Force
    StartUninstall
}

function New-SSLCerts {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )

    Initialize
    LoadCofigurations -ConfigName "SSLConfiguration"

    Import-Module "$PSScriptRoot\Common\SSL\SSL-Module.psm1" -Force

    if ($PSBoundParameters["Force"]) {
        StartSSLCertsCreation -Force
    }
    else {
        StartSSLCertsCreation
    }
}

Export-ModuleMember -Function "Install-Sitecore"
Export-ModuleMember -Function "Uninstall-Sitecore"
Export-ModuleMember -Function "New-SSLCerts"