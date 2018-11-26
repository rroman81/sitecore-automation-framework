
Properties {
  $ProjectRoot = $env:BHProjectRoot
  if (-not $ProjectRoot) {
    $ProjectRoot = "$PSScriptRoot\.."
  }

  $ModuleName = "Sitecore.Automation.Framework"

  $Timestamp = Get-Date -uformat "%Y%m%d-%H%M%S"
  $PSVersion = $PSVersionTable.PSVersion.Major
  $separator = '----------------------------------------------------------------------'
}


Task default -Depends Test

Task Publish -Depends Test {
  $APIKey = $env:MyGetFeedApiKey
  $PSrepositoryName = $env:SAFMyGetRepository
  
  Import-Module PowerShellGet
  if ( (Get-PSRepository RomasMyGetFeed -ErrorAction SilentlyContinue ) -eq $null) {
      $PSGalleryPublishUri = 'https://www.myget.org/F/psromaoneget/api/v2/package'
      $PSGallerySourceUri = 'https://www.myget.org/F/psromaoneget/api/v2'
      Register-PSRepository -Name RomasMyGetFeed -SourceLocation $PSGallerySourceUri -PublishLocation $PSGalleryPublishUri -InstallationPolicy Trusted
  }
    
  Publish-Module -Path "$ProjectRoot\$ModuleName\" -NuGetApiKey $APIKey -Repository RomasMyGetFeed
}

Task Test -Depends Compile {
  Test-ModuleManifest "$ProjectRoot\$ModuleName\$ModuleName.psd1" | Out-Null
  "Testing Module manifest has completed successfully!"
 }

Task Compile {
   "Compilation Complete"
 }