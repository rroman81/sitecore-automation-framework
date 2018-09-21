Import-Module "$PSScriptRoot\WebAdministration-Module.psm1" -Force
$ErrorActionPreference = "Stop"

function RefreshEnvironment {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User") 
    refreshenv
}

function DownloadAndUnzip {
    [CmdletBinding()]
    Param(
        [string]$toolName,
        [string]$toolFolder,
        [string]$toolZip,
        [string]$toolSourceFile,
        [string]$installRoot
    )

    if (!(Test-Path -Path $toolFolder)) {
        if (!(Test-Path -Path $toolZip)) {
            Write-Output "Downloading $toolName..."
            Start-BitsTransfer -Source $toolSourceFile -Destination $toolZip
        }

        Write-Output "Extracting $toolName to $toolFolder..."
        Expand-Archive $toolZip -DestinationPath $installRoot
    }
}

function DeleteServices {
    [CmdletBinding()]
    Param
    (
        [string[]]$Services
    )

    Write-Output "Deleting existing services..."

    taskkill /F /IM mmc.exe

    foreach ($service in $Services) {
        if (Get-Service $service -ErrorAction SilentlyContinue) {
            Write-Output "Stopping '$service' service..."
            nssm stop $service
            Write-Output "Deleting '$service' service..."
            nssm remove $service confirm
        }
        else {
            Write-Warning "Service '$service' not found..."
        }
    }

    Write-Output "Deleting existing services done."
}

Export-ModuleMember -Function "DeleteServices"
Export-ModuleMember -Function "DownloadAndUnzip"
Export-ModuleMember -Function "RefreshEnvironment"