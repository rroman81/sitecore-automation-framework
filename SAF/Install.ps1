Param(
	[switch]$Restarted
)

$ErrorActionPreference = "Stop"

function RestartPowerShell {
    Write-Warning "PowerShell restart is required. Restarting..."
	Start-Sleep -s 5
	Clear-Host
    & "$env:WINDIR\system32\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -NoExit -File "$PSScriptRoot\Install.ps1" -Restarted
}

function LoadLatestPSModule {
    [CmdletBinding()]
    Param
    (
        [string]$Name,
		[switch]$AllowPrerelease
    )

    if (Get-Module $Name -ListAvailable) {
        Write-Output "$Name module is installed. Checking for updates..."
        $currentModule = Import-Module $Name -PassThru
        $onlineModule = Find-Module $Name
        if ($onlineModule.version -gt $currentModule.version) {
            Write-Output "Update is available. Updating from $($currentModule.version) to $($onlineModule.version)..."
            if (!(Test-Path -Path "$($currentModule.ModuleBase)\PSGetModuleInfo.xml")) {
                if($AllowPrerelease.IsPresent){
					Install-Module $Name -AllowClobber -Force -AllowPrerelease
				}
				else {
					Install-Module $Name -AllowClobber -Force
				}
            }
            else {
                Update-Module $Name -Force
            }
        }
        else {
            Write-Output "No updates found..."
        }
    }
    else {
        Write-Output "$Name module is not installed. Installing..."

        if($AllowPrerelease.IsPresent) { 
			Install-Module $Name -AllowClobber -Force -AllowPrerelease
		}
		else {
			Install-Module $Name -AllowClobber -Force
		}
    }

    Get-Module $Name | Remove-Module -Force
    Import-Module $Name
}

function ConfigurePSGallery {
    Write-Output "Ensuring NuGet package provider..."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null

    # Ensure Trusted, so that users are not prompted before installing modules from that source.
    Write-Output "Trusting PSGallery..."
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    LoadLatestPSModule -Name PowerShellGet
	LoadLatestPSModule -Name PackageManagement
}

if(!(Get-Module Sitecore.Automation.Framework -ListAvailable) -and !($Restarted.IsPresent)) { # new install of the module
	Write-Output "Sitecore.Automation.Framework installer is verifying the prerequisites..."
	ConfigurePSGallery
	RestartPowerShell
}

LoadLatestPSModule -Name Sitecore.Automation.Framework -AllowPrerelease
Write-Output "Sitecore.Automation.Framework is ready for usage! Enjoy!"
