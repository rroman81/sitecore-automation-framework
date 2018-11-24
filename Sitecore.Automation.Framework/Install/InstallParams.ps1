If (Test-Path $env:Temp)
{
    $SAFInstallPackageDir = "$env:Temp\SAF\package"    
} else {
    $SAFInstallPackageDir = "$PSScriptRoot\..\temp\package"
}
Write-Verbose "Set Install Package Directory to $SAFInstallPackageDir"
