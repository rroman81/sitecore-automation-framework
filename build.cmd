@echo off

:: Download NuGet
if not exist ".\build\tools" mkdir ".\build\tools"
if not exist ".\build\tools\nuget" mkdir ".\build\tools\nuget"
if not exist ".\build\tools\nuget\nuget.exe" powershell -Command "Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile .\build\tools\nuget\nuget.exe"

:: Download Psake
set nuget=.\build\tools\nuget\nuget.exe
set EnableNuGetPackageRestore=true
if not exist ".\build\tools\psake\tools\psake\psake.cmd" %nuget% install psake -ExcludeVersion -NonInteractive -OutputDirectory ".\build\tools" -Verbosity quiet

call .\build\tools\psake\tools\psake\psake.cmd .\build\build.ps1 %*