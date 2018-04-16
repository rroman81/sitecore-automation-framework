Import-Module "$PSScriptRoot\Common\Initialization-Module.psm1" -Force
Import-Module "$PSScriptRoot\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Set-ExecutionPolicy Bypass -Scope Process -Force

$global:Configuration = $null
$global:Pipelines = Get-Content -Raw -Path "$PSScriptRoot\common\Pipelines.json" | ConvertFrom-Json

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

    if ($global:Configuration.offlineMode -eq $false) {
        ConfigurePSGallery
        ConfigureChoco
        RefreshEnvironment
    }
    else {
        Write-Warning "SAF is running in offline mode. It won't use PSGallery and Chocolatey. That means you'll have more to do by yourself ;)"
        Start-Sleep -s 5
    }

    Write-Warning "SAF initialization is done."
}

function Install-Sitecore {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )

    LoadCofigurations -ConfigName "InstallConfiguration"
    Initialize

    Import-Module "$PSScriptRoot\Install\OnPrem\Install-Module.psm1" -Force

    if ($Force.IsPresent) {
        StartInstall -Force
    }
    else {
        StartInstall
    }
}

function Uninstall-Sitecore {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )

    LoadCofigurations -ConfigName "InstallConfiguration"
    Initialize

    Import-Module "$PSScriptRoot\Install\OnPrem\Uninstall-Module.psm1" -Force
   
    if ($Force.IsPresent) {
        StartUninstallSitecore -Force
    }
    else {
        StartUninstallSitecore
    }
}

function Uninstall-Solr {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )

    LoadCofigurations -ConfigName "SolrConfiguration"
    Initialize

    Import-Module "$PSScriptRoot\Install\OnPrem\Uninstall-Module.psm1" -Force
   
    if ($Force.IsPresent) {
        StartUninstallSolr -Force
    }
    else {
        StartUninstallSolr
    }
}

function New-SSLCerts {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )

    LoadCofigurations -ConfigName "SSLConfiguration"
    Initialize

    Import-Module "$PSScriptRoot\Common\SSL\SSL-Module.psm1" -Force

    if ($Force.IsPresent) {
        StartSSLCertsCreation -Force
    }
    else {
        StartSSLCertsCreation
    }
}

function Import-SSLCerts {
    LoadCofigurations -ConfigName "SSLConfiguration"
    Initialize

    Import-Module "$PSScriptRoot\Common\SSL\SSL-Module.psm1" -Force
    ImportCerts -Password $global:Configuration.password
}

function Set-SSLCertsAppPoolsAccess {
    LoadCofigurations -ConfigName "SSLConfiguration"
    Initialize

    Import-Module "$PSScriptRoot\Common\SSL\SSL-Module.psm1" -Force
    SetSSLCertsAppPoolsAccess -Prefix $global:Configuration.prefix -Hostnames $global:Configuration.hostNames 
}

function Initialize-Solr {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )

    LoadCofigurations -ConfigName "SolrConfiguration"
    Initialize

    Import-Module "$PSScriptRoot\Install\OnPrem\Solr\Solr-Module.psm1" -Force
   
    if ($Force.IsPresent) {
        StartSetup -Force
    }
    else {
        StartSetup
    }
}

Export-ModuleMember -Function "Install-Sitecore"
Export-ModuleMember -Function "Uninstall-Sitecore"
Export-ModuleMember -Function "Uninstall-Solr"
Export-ModuleMember -Function "New-SSLCerts"
Export-ModuleMember -Function "Import-SSLCerts"
Export-ModuleMember -Function "Set-SSLCertsAppPoolsAccess"
Export-ModuleMember -Function "Initialize-Solr"