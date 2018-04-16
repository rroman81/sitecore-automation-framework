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
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\AllInOne"
# New-SSLCerts
# Import-SSLCerts
# Initialize-Solr
# Install-Sitecore
# Uninstall-Sitecore
# Uninstall-Solr

############### END XP0 ###################


############### START XM1 ###################

# XM SSL
# Set-Location "$rootDir\Examples\Install\OnPrem\XM\00-SSL"
# New-SSLCerts
# Import-SSLCerts

# XM Solr
# Set-Location "$rootDir\Examples\Install\OnPrem\XM\01-Solr"
# Initialize-Solr

# XM Content Management
# Set-Location "$rootDir\Examples\Install\OnPrem\XM\02-ContentManagement"
# Install-Sitecore

# XM Content Delivery
# Set-Location "$rootDir\Examples\Install\OnPrem\XM\03-ContentDelivery"
# Install-Sitecore

############### END XM1 ###################


############### START XP1 ###################

# XP SSL Certs
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\Scaled\00-SSL"
# New-SSLCerts
# Import-SSLCerts

# XP Solr
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\Scaled\01-Solr"
# Initialize-Solr

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

# XP Set-SSLCertsAppPoolsAccess
# Set-Location "$rootDir\Examples\Install\OnPrem\XP\Scaled\00-SSL"
# Set-SSLCertsAppPoolsAccess

############### END XP1 ###################