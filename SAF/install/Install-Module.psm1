Import-Module "$PSScriptRoot\..\common\Run-Pipelines.psm1"
$ErrorActionPreference = "Stop"

function ImportSIF {
    Write-Output "Import Sitecore Installation Framework (SIF) started..."

    $repositoryUrl = "https://sitecore.myget.org/F/sc-powershell/api/v2"
    $repositoryName = "SitecoreGallery"

    # Check to see whether that location is registered already
    $existing = Get-PSRepository -Name $repositoryName -ErrorAction Ignore

    # If not, register it
    if ($existing -eq $null) {
        Register-PSRepository -Name $repositoryName -SourceLocation $repositoryUrl -InstallationPolicy Trusted 
    }

    if (Get-Module "SitecoreInstallFramework" -ListAvailable) {
        Update-Module "SitecoreInstallFramework"
    }
    else {
        Install-Module "SitecoreInstallFramework"
    }

    if (!(Get-Module "SitecoreInstallFramework")) {
        Import-Module "SitecoreInstallFramework"
    }

    Write-Output "Import Sitecore Installation Framework (SIF) done."
}

function ResolvePipeline {
    return "install$($global:Configuration.hosting)$($global:Configuration.serverRole)"
}

function InitializeItems {
    [CmdletBinding()]
    Param
    (
        [string]$Pipeline
    )

    switch ($Pipeline) {
        "installOnPremAllInOne" {
            $installPackageDir = "$PSScriptRoot\..\temp\package"
            $global:Items.Add("SAFInstallPackageDir", $installPackageDir)
    
            $solrServiceDir = "$($global:Configuration.search.solr.installDir)\solr-$($global:Configuration.search.solr.version)"
            $global:Items.Add("SolrServiceDir", $solrServiceDir)
    
            $global:Items.Add("SolrServiceUrl", "https://$($global:Configuration.search.solr.hostName):$($global:Configuration.search.solr.port)/solr")
    
            $certName = "$($global:Configuration.prefix).xconnect_client"
            $global:Items.Add("XConnectCertName", $certName)

            break
        }
        "installOnPremSolr" {
            $solrServiceDir = "$($global:Configuration.search.solr.installDir)\solr-$($global:Configuration.search.solr.version)"
            $global:Items.Add("SolrServiceDir", $solrServiceDir)
            
            break
        }
     }
}

function StartInstall {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )
    
    $pipeline = ResolvePipeline
    InitializeItems -Pipeline $pipeline

    if ($PSBoundParameters["Force"]) {
        RunSteps -Pipeline $pipeline -Force
    }
    else {
        RunSteps -Pipeline $pipeline
    }
}

Export-ModuleMember -Function "StartInstall"
Export-ModuleMember -Function "ImportSIF"


