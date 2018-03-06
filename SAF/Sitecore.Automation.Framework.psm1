Import-Module "$PSScriptRoot\common\Initialization-Module.psm1" -Force

$ErrorActionPreference = "Stop"
Set-ExecutionPolicy Bypass -Scope Process -Force

$global:Configuration = $null
$global:Items = $null
$global:Pipelines = Get-Content -Raw -Path "$PSScriptRoot\common\Pipelines.json" | ConvertFrom-Json

function Initialize {

    [CmdletBinding()]
    Param
    (
        [string]$ConfigFile,
        [string]$PipelinesFile
    )

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

    $global:Items = @{}
    $global:Configuration = Get-Content -Raw -Path $ConfigFile | ConvertFrom-Json
    if (!([string]::IsNullOrEmpty($PipelinesFile))) {
        $global:Pipelines = Get-Content -Raw -Path $PipelinesFile | ConvertFrom-Json
    }

    Write-Warning "SAF initialization is done."
}

function Install-Sitecore {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$ConfigFile,
        [string]$PipelinesFile,
        [switch]$Force
    )

    Initialize -ConfigFile $ConfigFile -PipelinesFile $PipelinesFile

    Import-Module "$PSScriptRoot\Install\OnPrem\Install-Module.psm1" -Force

    if ($PSBoundParameters["Force"]) {
        StartInstall -Force
    }
    else {
        StartInstall
    }
}

Export-ModuleMember -Function "Install-Sitecore"