Import-Module "$PSScriptRoot\..\Run-Pipelines.psm1" -Force
$ErrorActionPreference = "Stop"

function CleanCertStore {
    [CmdletBinding()]
    Param(
        [string]$RootCertName,
        [string]$Store
    )

    Write-Output "Cleaning SSL Certificate Store '$Store' started..."

    $certs = Get-ChildItem -Path "cert:\$Store\My" | Where-Object { $_.Issuer -Like "CN=$RootCertName*" }
    if ($certs -ne $null) {
        foreach ($cert in $certs) {
            Remove-Item -Path "cert:\$Store\My\$($cert.Thumbprint)" -DeleteKey -Force
            Write-Output "Removed SSL Certificate with Subject = $($cert.Subject) and Thumbprint = $($cert.Thumbprint)"
        }
    }

    $rootCert = Get-ChildItem -Path "cert:\$Store\Root" | Where-Object { $_.Subject -Like "CN=$RootCertName*" }
    if ($rootCert -ne $null) {
        Remove-Item -Path "cert:\$Store\Root\$($rootCert.Thumbprint)" -DeleteKey -Force
        Write-Output "Removed SSL Certificate with Subject = $($rootCert.Subject) and Thumbprint = $($rootCert.Thumbprint)"
    }

    Write-Output "Cleaning SSL Certificate Store '$Store' done."
}

function GenerateRootCert {
    [CmdletBinding()]
    Param(
        [string]$RootCertName
    )

    Write-Output "Generating '$RootCertName' Root CA Certificate started..."

    $certParams = @{
        Path         = "$PSScriptRoot\create_rootcert.json"
        CertPath     = $env:TEMP
        RootCertName = $RootCertName
    }

    Install-SitecoreConfiguration @certParams

    Write-Output "Generating '$RootCertName' Root CA Certificate done."
}

function GenerateCert {
    [CmdletBinding()]
    Param(
        [string]$CertName,
        [string]$RootCertName
    )

    Write-Output "Generating '$CertName' Certificate started..."
    
    $certParams = @{
        Path         = "$PSScriptRoot\create_cert.json"
        CertPath     = $env:TEMP
        RootCertName = $RootCertName
        CertName     = $CertName
    }

    Install-SitecoreConfiguration @certParams

    Write-Output "Generating '$CertName' Certificate done."
}

function ExportCert {
    [CmdletBinding()]
    Param(
        [string]$RootCertName,
        [string]$ExportPath,
        [string]$Password
    )
    # Export PFX certificates along with private key
    
    $certDestPath = Join-Path -Path $ExportPath -ChildPath "SitecoreSSLCertificates.pfx"
    $rootCertDestPath = Join-Path -Path $ExportPath -ChildPath "SitecoreRootSSLCertificate.pfx"
    $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

    Write-Output "Exporting '$RootCertName' Root CA cetificate started..."
    Get-ChildItem -Path cert:\CurrentUser\My | Where-Object { $_.Subject -Like "CN=$RootCertName*" } | Export-PfxCertificate -FilePath $rootCertDestPath -Password $securePassword | Out-Null
    Write-Output "Exporting '$RootCertName' Root CA cetificate done."

    Write-Output "Exporting all certificates issued by '$RootCertName' started..."
    Get-ChildItem -Path cert:\LocalMachine\My | Where-Object { $_.Issuer -Like "CN=$RootCertName*" } | Export-PfxCertificate -FilePath $certDestPath -Password $securePassword | Out-Null
    Write-Output "Exporting all certificates issued by '$RootCertName' done."
    
    try {
        CleanCertStore -RootCertName $RootCertName -Store "LocalMachine"
        CleanCertStore -RootCertName $RootCertName -Store "CurrentUser"
    }
    catch {
        Write-Warning "Exception occurred"
        $exception = $_.Exception | Format-List -Force | Out-String
        Write-Warning $exception
    }
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
Export-ModuleMember -Function "GenerateCert"
Export-ModuleMember -Function "ExportCert"