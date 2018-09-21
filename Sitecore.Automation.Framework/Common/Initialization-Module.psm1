$ErrorActionPreference = "Stop"
function ConfigureChoco {
    Write-Output "SAF loves the latest Chocolatey and is getting it..."
        try {
        choco | Out-Null
        choco upgrade chocolatey --limitoutput
    }
    catch {
        Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
    }
    choco feature enable -n allowGlobalConfirmation | Out-Null
    Write-Output "SAF is happy with having the latest Choco!"
}

function ConfigurePSGallery {
    Write-Output "SAF is ensuring NuGet package provider..."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null

    # Ensure Trusted, so that users are not prompted before installing modules from that source.
    Write-Output "SAF is trusting PSGallery..."
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}

Export-ModuleMember -Function "ConfigureChoco"
Export-ModuleMember -Function "ConfigurePSGallery"