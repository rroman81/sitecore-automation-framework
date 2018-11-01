
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

Task Deploy -Depends Test {

}

Task Test -Depends Compile {
  Test-ModuleManifest "$ProjectRoot\$ModuleName\$ModuleName.psd1" | Out-Null
 }

Task Compile {
   "Compilation Complete"
 }