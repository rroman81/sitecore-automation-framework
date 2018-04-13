Import-Module "$PSScriptRoot\..\Run-Pipelines.psm1" -Force
$ErrorActionPreference = "Stop"

function IsInstallWithSAFCerts {
    $dir = Get-Location
    $pfxRootCert = "$dir\SitecoreRootSSLCertificate_SAF.pfx"
    if (!(Test-Path $pfxRootCert)) {
        $return $false
    }
    $pfxCert = "$dir\SitecoreSSLCertificates_SAF.pfx"
    if (!(Test-Path $pfxCert)) {
        return $false
    }
    return $true
}

function BuildRootCertName {
    [CmdletBinding()]
    Param(
        [string]$Prefix
    )

    $crt = "$($Prefix)_SitecoreRoot_SAF"
    return $crt
}

function BuildClientCertName {
    [CmdletBinding()]
    Param(
        [string]$Prefix
    )

    $crt = ""
    if (IsInstallWithSAFCerts) {
        $crt = "$($Prefix)_SitecoreClient_SAF"
    }
   
    return $crt
}

function BuildServerCertName {
    [CmdletBinding()]
    Param(
        [string]$Prefix
    )

    $crt = ""
    if (IsInstallWithSAFCerts) {
        $crt = "$($Prefix)_SitecoreServer_SAF"
    }

    return $crt
}

function FindCert {
    [CmdletBinding()]
    Param(
        [string]$Cert
    )

    try {
        $cert = Get-ChildItem -Path "cert:\LocalMachine\My" | Where-Object FriendlyName -eq $Cert
    
        if ($cert -eq $null) {
            $cert = Get-ChildItem -Path "cert:\LocalMachine\Root" | Where-Object FriendlyName -eq $Cert
        }

        if ($cert -eq $null) {
            $cert = Get-Item "cert:\LocalMachine\My\$Cert"
        }
        if ($cert -eq $null) {
            $cert = Get-Item "cert:\LocalMachine\Root\$Cert"
        }

        return $cert
    }
    catch {
        Write-Warning "Exception occurred while looking for SSLCert."
        $exception = $_.Exception | Format-List -Force | Out-String
        Write-Warning $exception
        return null
    }
}

function CleanCertStore {
    [CmdletBinding()]
    Param(
        [string]$Prefix,
        [string]$Store
    )

    $rootCertName = BuildRootCertName -Prefix $Prefix
    Write-Output "Cleaning Sitecore SSL Certificates started..."

    $certs = Get-ChildItem -Path "cert:\$Store\My" | Where-Object { $_.Issuer -Like "CN=$rootCertName*" }
    if ($certs -ne $null) {
        foreach ($cert in $certs) {
            Write-Output "Removing SSL Certificate with Subject = '$($cert.Subject)' and Thumbprint = '$($cert.Thumbprint)'..."
            Remove-Item -Path "cert:\$Store\My\$($cert.Thumbprint)" -DeleteKey -Force
        }
    }

    $rootCert = Get-ChildItem -Path "cert:\$Store\Root" | Where-Object FriendlyName -eq $rootCertName
    if ($rootCert -ne $null) {
        Write-Output "Removing SSL Root Certificate with Subject = '$($rootCert.Subject)' and Thumbprint = '$($rootCert.Thumbprint)'..."
        Remove-Item -Path "cert:\$Store\Root\$($rootCert.Thumbprint)" -DeleteKey -Force
    }

    Write-Output "Cleaning Sitecore SSL Certificates done."
}

function GenerateRootCert {
    [CmdletBinding()]
    Param(
        [string]$Prefix,
        [int]$ValidYears = 10
    )

    $rootCertName = BuildRootCertName -Prefix $Prefix

    Write-Output "Generating '$rootCertName' Root CA Certificate started..."
    New-SelfSignedCertificate -CertStoreLocation cert:\CurrentUser\My -DnsName "$rootCertName" -KeyusageProperty All -KeyUsage DigitalSignature, CertSign -KeyExportPolicy Exportable -NotAfter (Get-Date).AddYears($ValidYears) -FriendlyName $rootCertName -Verbose
    Write-Output "Generating '$rootCertName' Root CA Certificate done."
}

function GenerateServerCert {
    [CmdletBinding()]
    Param(
        [string]$Prefix,
        [string]$Type,
        [string[]]$Hostnames,
        [int]$ValidYears = 10
    )

    $rootCertName = BuildRootCertName -Prefix $Prefix
    $rootCert = Get-ChildItem Cert:\CurrentUser\My | Where-Object FriendlyName -eq $rootCertName
    if ($rootCert -eq $null) {
        throw "Can not find SSL Root CA Certificate with name '$rootCertName'..."
    }
    $serverCertName = BuildServerCertName -Prefix $Prefix
    
    Write-Output "Generating '$serverCertName' Certificate started..."
    New-SelfSignedCertificate -CertStoreLocation cert:\CurrentUser\My -Signer $rootCert -Subject $serverCertName -DnsName $Hostnames -KeyusageProperty All -KeyUsage KeyEncipherment, DigitalSignature -KeyExportPolicy Exportable -NotAfter (Get-Date).AddYears($ValidYears) -FriendlyName $serverCertName
    Write-Output "Generating '$serverCertName' Certificate done."
}

function GenerateClientCert {
    [CmdletBinding()]
    Param(
        [string]$Prefix,
        [string[]]$Hostnames,
        [int]$ValidYears = 10
    )

    $rootCertName = BuildRootCertName -Prefix $Prefix
    $rootCert = Get-ChildItem Cert:\CurrentUser\My | Where-Object FriendlyName -eq $rootCertName
    if ($rootCert -eq $null) {
        throw "Can not find SSL Root CA Certificate with name '$rootCertName'..."
    }
    $clientCertName = BuildClientCertName -Prefix $Prefix

    Write-Output "Generating '$clientCertName' Certificate started..."
    New-SelfSignedCertificate -CertStoreLocation cert:\CurrentUser\My -Signer $rootCert -Subject $clientCertName -DnsName $Hostnames -KeyusageProperty All -KeyUsage KeyEncipherment, DigitalSignature -KeyExportPolicy Exportable -NotAfter (Get-Date).AddYears($ValidYears) -FriendlyName $clientCertName
    Write-Output "Generating '$clientCertName' Certificate done."
}

function ExportCerts {
    [CmdletBinding()]
    Param(
        [string]$Prefix,
        [string]$ExportPath,
        [string]$Password
    )

    $rootCertName = BuildRootCertName -Prefix $Prefix
    
    # Export PFX certificates along with private key
    $certDestPath = Join-Path -Path $ExportPath -ChildPath "SitecoreSSLCertificates_SAF.pfx"
    $rootCertDestPath = Join-Path -Path $ExportPath -ChildPath "SitecoreRootSSLCertificate_SAF.pfx"
    $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

    Write-Output "Exporting '$rootCertName' Root CA cetificate started..."
    Get-ChildItem -Path cert:\CurrentUser\My | Where-Object FriendlyName -eq $rootCertName | Export-PfxCertificate -FilePath $rootCertDestPath -Password $securePassword -Verbose
    Write-Output "Exporting '$rootCertName' Root CA cetificate done."

    Write-Output "Exporting all certificates issued by '$rootCertName' started..."
    Get-ChildItem -Path cert:\CurrentUser\My | Where-Object { $_.Issuer -Like "CN=$rootCertName*" } | Export-PfxCertificate -FilePath $certDestPath -Password $securePassword -Verbose
    Write-Output "Exporting all certificates issued by '$rootCertName' done."
    
    try {
        CleanCertStore -Prefix $Prefix -Store "CurrentUser"
    }
    catch {
        Write-Warning "Exception occurred"
        $exception = $_.Exception | Format-List -Force | Out-String
        Write-Warning $exception
    }
}

function ImportCerts {
    [CmdletBinding()]
    Param(
        [string]$Password
    )

    Write-Output "Importing SSL Certificates started..."

    $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

    $dir = Get-Location

    $pfxRootCert = "$dir\SitecoreRootSSLCertificate_SAF.pfx"
    Import-PfxCertificate -FilePath $pfxRootCert -CertStoreLocation "Cert:\LocalMachine\Root" -Password $securePassword -Exportable -Verbose

    $pfxCert = "$dir\SitecoreSSLCertificates_SAF.pfx"
    Import-PfxCertificate -FilePath $pfxCert -CertStoreLocation "Cert:\LocalMachine\My" -Password $securePassword -Exportable -Verbose

    Write-Output "Importing SSL Certificates done."
}

function SetSSLCertsAppPoolsAccess {
    [CmdletBinding()]
    Param(
        [string]$Prefix,
        [string[]]$Hostnames
    )

    Write-Output "Set SSL Certificates AppPools access started..."
    
    $clientCertName = BuildClientCertName -Prefix $Prefix
    
    foreach ($hostName in $Hostnames) {
        if (Test-Path "IIS:\AppPools\$hostName") {
            $params = @{
                Path         = "$PSScriptRoot\set-sslcerts-access.json"
                XConnectCert = $clientCertName
                AppPoolName  = $hostName
            }
            Install-SitecoreConfiguration @params
        }
        else {
            Write-Warning -Message "Could not find IIS AppPool '$hostName'. Skipping set access..."
        }
    }

    Write-Output "Set SSL Certificates AppPools access done."
}

function StartSSLCertsCreation {
    [CmdletBinding()]
    Param
    (
        [switch]$Force
    )
    
    $pipeline = "newSSLCerts"

    if ($PSBoundParameters["Force"]) {
        RunSteps -Pipeline $pipeline -Force
    }
    else {
        RunSteps -Pipeline $pipeline
    }
}

Export-ModuleMember -Function "StartSSLCertsCreation"
Export-ModuleMember -Function "GenerateRootCert"
Export-ModuleMember -Function "GenerateServerCert"
Export-ModuleMember -Function "GenerateClientCert"
Export-ModuleMember -Function "ExportCerts"
Export-ModuleMember -Function "BuildClientCertName"
Export-ModuleMember -Function "BuildServerCertName"
Export-ModuleMember -Function "FindCert"
Export-ModuleMember -Function "CleanCertStore"
Export-ModuleMember -Function "ImportCerts"
Export-ModuleMember -Function "SetSSLCertsAppPoolsAccess"