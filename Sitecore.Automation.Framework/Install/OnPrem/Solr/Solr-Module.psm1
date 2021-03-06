Import-Module "$PSScriptRoot\..\..\..\Common\Run-Pipelines.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\Common\Utils-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\Common\WebAdministration-Module.psm1" -Force
$ErrorActionPreference = "Stop"

function InstallSolr {
    [CmdletBinding()]
    Param
    (
        [string]$Version,
        [string]$InstallDir,
        [string]$HostName,
        [int]$Port,
        [string]$SSLCert,
        [string]$ServiceDir,
        [string]$ServiceName,
        [string]$ServiceDisplayName,
        [string]$ServiceDescription
    )
   
    Write-Output "Solr installation started..."
    
    $services = @($ServiceName)
    DeleteServices -Services $services

    if (Test-Path "$installDir\solr-$Version") {
        Write-Output "Cleaning '$installDir\solr-$Version' before install..."
        Remove-Item -Path "$installDir\solr-$Version" -Recurse -Force | Out-Null
    }

    $downloadFolder = "~\Downloads"
    $solrPackage = "https://archive.apache.org/dist/lucene/solr/$Version/solr-$Version.zip"
    $solrZip = "$downloadFolder\$ServiceName.zip"
    DownloadAndUnzip "Solr" $ServiceDir $solrZip $solrPackage $InstallDir
    
    $JREVersion = Get-ChildItem "HKLM:\SOFTWARE\JavaSoft\Java Runtime Environment" | Select-Object -expa pschildname -Last 1
    $JREPath = "C:\Program Files\Java\jre$JREVersion"
    $jreVal = [Environment]::GetEnvironmentVariable("JAVA_HOME", [EnvironmentVariableTarget]::Machine)
    if ($jreVal -ne $JREPath) {
        Write-Output "Setting JAVA_HOME environment variable..."
        [Environment]::SetEnvironmentVariable("JAVA_HOME", $JREPath, [EnvironmentVariableTarget]::Machine)
    }
    
    if ($HostName -ne "localhost") {
        AddHostFileEntry -IP "127.0.0.1" -HostName $HostName
    }

    # Export the cert to pfx using solr's default password
    if (!(Test-Path -Path "$ServiceDir\server\etc\solr-ssl.keystore.pfx")) {
        Write-Output "Exporting SSL Certificate for Solr to use..."

        $cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object FriendlyName -eq $SSLCert
        $certStore = "$ServiceDir\server\etc\solr-ssl.keystore.pfx"
        $certPwd = ConvertTo-SecureString -String "secret" -Force -AsPlainText
        $cert | Export-PfxCertificate -FilePath $certStore -Password $certpwd | Out-Null
    }

    # Update solr cfg to use keystore & right host name
    if (!(Test-Path -Path "$ServiceDir\bin\solr.in.cmd.old")) {
        Write-Output "Rewriting solr config..."

        $cfg = Get-Content "$ServiceDir\bin\solr.in.cmd"
        Rename-Item "$ServiceDir\bin\solr.in.cmd" "$ServiceDir\bin\solr.in.cmd.old"
        $newCfg = $cfg | ForEach-Object { $_ -replace "REM set SOLR_SSL_KEY_STORE=etc/solr-ssl.keystore.jks", "set SOLR_SSL_KEY_STORE=$certStore" }
        $newCfg = $newCfg | ForEach-Object { $_ -replace "REM set SOLR_SSL_KEY_STORE_PASSWORD=secret", "set SOLR_SSL_KEY_STORE_PASSWORD=secret" }
        $newCfg = $newCfg | ForEach-Object { $_ -replace "REM set SOLR_SSL_TRUST_STORE=etc/solr-ssl.keystore.jks", "set SOLR_SSL_TRUST_STORE=$certStore" }
        $newCfg = $newCfg | ForEach-Object { $_ -replace "REM set SOLR_SSL_TRUST_STORE_PASSWORD=secret", "set SOLR_SSL_TRUST_STORE_PASSWORD=secret" }
        $newCfg = $newCfg | ForEach-Object { $_ -replace "REM set SOLR_HOST=192.168.1.1", "set SOLR_HOST=$HostName" }
        $newCfg | Set-Content "$ServiceDir\bin\solr.in.cmd"
    }
    
    $svc = Get-Service "$ServiceName" -ErrorAction SilentlyContinue
    
    if (!($svc)) {
        Write-Output "Installing Solr service..."
        nssm install "$ServiceName" "$ServiceDir\bin\solr.cmd" "-f" "-p $Port"
        nssm set "$ServiceName" DisplayName "$ServiceDisplayName" 
        nssm set "$ServiceName" Description "$ServiceDescription"
        $svc = Get-Service "$ServiceName" -ErrorAction SilentlyContinue
    }

    if ($svc.Status -ne "Running") {
        Write-Output "Starting Solr service..."
        Start-Service "$ServiceName"
    }
    
    Write-Output "Solr installation done."
}

function ResolvePipeline {
    if ([string]::IsNullOrEmpty($global:Configuration.solr.serviceURL)) {
        return "install$($global:Configuration.hosting)Solr-$($global:Configuration.sitecoreMode)"
    }
    else {
        return "setup$($global:Configuration.hosting)SolrCoresViaHTTP-$($global:Configuration.sitecoreMode)"
    }
}

function StartSetup {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )
    
    $pipeline = ResolvePipeline
    
    if ($Force.IsPresent) {
        RunSteps -Pipeline $pipeline -Force
    }
    else {
        RunSteps -Pipeline $pipeline
    }
}

Export-ModuleMember -Function "StartSetup"
Export-ModuleMember -Function "InstallSolr"