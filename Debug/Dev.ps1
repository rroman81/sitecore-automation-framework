# Setup VS Code
# 1. Install Powershell Extension
# 2. Set "program": "${workspaceRoot}/Developer/Debug.ps1" in launch.json

### Initialization ###
$rootDir = "C:\Projects\sitecore-automation-framework"
Import-Module -Name "$rootDir\SAF\Sitecore.Automation.Framework.psm1" -Force
### Initialization ### 

############### Debug ###################

# AllInOne
Set-Location "$rootDir\Debug\Install\AllInOne"
#New-SSLCerts
Install-Sitecore
