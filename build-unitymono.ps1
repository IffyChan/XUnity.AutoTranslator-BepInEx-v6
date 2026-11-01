param(
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"
$rootDir = $PSScriptRoot
$distDir = Join-Path $rootDir "dist\BepInEx-UnityMono"
$pluginDir = Join-Path $distDir "BepInEx\plugins\XUnity.AutoTranslator"
$redirectorDir = Join-Path $distDir "BepInEx\plugins\XUnity.ResourceRedirector"
$coreDir = Join-Path $distDir "BepInEx\core"

Write-Host "Building projects for $Configuration..."
New-Item -ItemType Directory -Force -Path "$rootDir\dist\Translators\FullNET" | Out-Null
New-Item -ItemType Directory -Force -Path "$rootDir\dist\Developer\Developer" | Out-Null
$solDir = "$rootDir\"
dotnet build "$rootDir\src\XUnity.Common\XUnity.Common.csproj" -c $Configuration -f netstandard2.0 -p:SolutionDir="$solDir"
dotnet build "$rootDir\src\XUnity.ResourceRedirector\XUnity.ResourceRedirector.csproj" -c $Configuration -f netstandard2.0 -p:SolutionDir="$solDir"
dotnet build "$rootDir\src\XUnity.AutoTranslator.Plugin.Core\XUnity.AutoTranslator.Plugin.Core.csproj" -c $Configuration -f netstandard2.0 -p:SolutionDir="$solDir"
dotnet build "$rootDir\src\XUnity.AutoTranslator.Plugin.BepInEx.UnityMono\XUnity.AutoTranslator.Plugin.BepInEx.UnityMono.csproj" -c $Configuration -f netstandard2.0 -p:SolutionDir="$solDir"
dotnet build "$rootDir\src\XUnity.ResourceRedirector.BepInEx.UnityMono\XUnity.ResourceRedirector.BepInEx.UnityMono.csproj" -c $Configuration -f netstandard2.0 -p:SolutionDir="$solDir"

Write-Host "Assembling distribution directory at $distDir..."
if (Test-Path $distDir) {
    Remove-Item -Recurse -Force $distDir
}

New-Item -ItemType Directory -Force -Path $pluginDir | Out-Null
New-Item -ItemType Directory -Force -Path $redirectorDir | Out-Null
New-Item -ItemType Directory -Force -Path $coreDir | Out-Null

$binAuto = "$rootDir\src\XUnity.AutoTranslator.Plugin.BepInEx.UnityMono\bin\$Configuration\netstandard2.0"
$binCore = "$rootDir\src\XUnity.AutoTranslator.Plugin.Core\bin\$Configuration\netstandard2.0"
$binCommon = "$rootDir\src\XUnity.Common\bin\$Configuration\netstandard2.0"
$binRedir = "$rootDir\src\XUnity.ResourceRedirector\bin\$Configuration\netstandard2.0"
$binRedirPlugin = "$rootDir\src\XUnity.ResourceRedirector.BepInEx.UnityMono\bin\$Configuration\netstandard2.0"
$libs = "$rootDir\libs"

# Copy AutoTranslator
Copy-Item "$binAuto\XUnity.AutoTranslator.Plugin.BepInEx.UnityMono.dll" $pluginDir
Copy-Item "$binCore\XUnity.AutoTranslator.Plugin.Core.dll" $pluginDir
Copy-Item "$binCommon\XUnity.Common.dll" $pluginDir
Copy-Item "$binCommon\XUnity.Common.dll" $coreDir
Copy-Item "$libs\ExIni.dll" $pluginDir

if (Test-Path "$binCore\XUnity.AutoTranslator.Plugin.ExtProtocol.dll") {
    Copy-Item "$binCore\XUnity.AutoTranslator.Plugin.ExtProtocol.dll" $pluginDir
}

# Copy ResourceRedirector
Copy-Item "$binRedirPlugin\XUnity.ResourceRedirector.BepInEx.UnityMono.dll" $redirectorDir
Copy-Item "$binRedir\XUnity.ResourceRedirector.dll" $redirectorDir

Copy-Item "$rootDir\README.md" "$pluginDir\README (AutoTranslator).md"

# Zip distribution
$zipPath = Join-Path "$rootDir\dist" "XUnity.AutoTranslator-BepInEx-UnityMono-5.6.3.1.zip"
if (Test-Path $zipPath) {
    Remove-Item -Force $zipPath
}

Write-Host "Compressing to $zipPath..."
Compress-Archive -Path "$distDir\*" -DestinationPath $zipPath -Force

Write-Host "Successfully packaged: $zipPath"
