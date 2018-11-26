If (Test-Path $env:Temp)
{
    $SAFInstallDir = "$env:Temp\SAF"
    $SAFInstallPackageDir = Join-Path $SAFInstallDir "package"
    if (-not (Test-Path $SAFInstallPackageDir)) {
        New-Item -ItemType Directory -Path $SAFInstallPackageDir
    }    
} else {
    $SAFInstallDir = "$PSScriptRoot\..\temp"
    $SAFInstallPackageDir = Join-Path $SAFInstallDir "package"
}
Write-Verbose "Set Install Package Directory to $SAFInstallPackageDir"
