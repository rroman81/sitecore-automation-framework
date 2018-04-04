Import-Module "$PSScriptRoot\Install-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$repositoryURL = $global:Configuration.sif.repositoryURL
$version = $global:Configuration.sif.version

ImportSIF -RepositoryURL $repositoryURL -Version $version