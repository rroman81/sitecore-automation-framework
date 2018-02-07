# Setup VS Code
# 1. Install Powershell Extension
# 2. Set "program": "${workspaceRoot}/Developer/Debug.ps1" in launch.json

### Configuration ###
$runtimeDir =  ""
$configFile = ""
### Configuration ###

### Initialization ###
$module = Join-Path -Path $runtimeDir -ChildPath "Sitecore.Automation.Framework.psm1"
Import-Module -Name $module -Force
### Initialization ###

############### Debug ###################
Install-Sitecore -ConfigFile $configFile

