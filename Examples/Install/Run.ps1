$ErrorActionPreference = "Stop"

# Setup VS Code
# 1. Install Powershell Extension
# 2. Set "program": "${workspaceRoot}/Developer/Debug.ps1" in launch.json

### Initialization ###
$rootDir = "C:\Projects\sitecore-automation-framework"
Import-Module -Name "$rootDir\SAF\Sitecore.Automation.Framework.psm1" -Force
### Initialization ### 


############### START XP0 ###################

# XP AllInOne
Set-Location "$rootDir\Examples\Install\OnPrem\XP\AllInOne"
# New-SSLCerts
# Install-Sitecore
Uninstall-Sitecore

############### END XP0 ###################


############### START XM1 ###################

# XM SSL
# Set-Location "$rootDir\Examples\Install\OnPrem\XM\Scaled\00-SSL"
# New-SSLCerts

# XM Solr
# Set-Location "$rootDir\Examples\Install\OnPrem\XM\Scaled\01-Solr"
# Install-Sitecore

# XM Content Management
# Set-Location "$rootDir\Examples\Install\OnPrem\XM\Scaled\02-ContentManagement"
# Install-Sitecore

# XM Content Delivery
# Set-Location "$rootDir\Examples\Install\OnPrem\XM\Scaled\03-ContentDelivery"
# Install-Sitecore

############### END XM1 ###################


############### START XP1 ###################

# XP SSL
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\Scaled\00-SSL"
# New-SSLCerts

# XP Solr
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\Scaled\01-Solr"
# Install-Sitecore

# XP xConnect Collection
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\Scaled\02-xConnectCollection"
# Install-Sitecore

# XP xConnect Collection Search
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\Scaled\03-xConnectCollectionSearch"
# Install-Sitecore

# XP xDB Reference Data
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\Scaled\04-xDBReferenceData"
# Install-Sitecore

# XP xDB Automation Operations
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\Scaled\05-xDBAutomationOperations"
# Install-Sitecore

# XP xDB Automation Reporting
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\Scaled\06-xDBAutomationReporting"
# Install-Sitecore

# XP Sitecore Processing
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\Scaled\07-Processing"
# Install-Sitecore

# XP Sitecore Reporting
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\Scaled\08-Reporting"
# Install-Sitecore

# XP Content Management
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\Scaled\09-ContentManagement"
# Install-Sitecore

# XP Content Delivery
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\Scaled\10-ContentDelivery"
# Install-Sitecore

############### END XP1 ###################