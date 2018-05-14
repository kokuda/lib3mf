<#
.SYNOPSIS
Build the MacOS, iOS, and iOS Simulator projects

.DESCRIPTION
Build the MacOS, iOS, and iOS Simulator projects as they were generated by GenerateMacOSiOS.ps1

.EXAMPLE
BuildMacOSiOSNuGet.ps1
#>

[CmdletBinding()]
param(
    [switch]$NoNuGet,
    [switch]$NoMacOS,
    [switch]$NoIOS,
    [switch]$NoSimulator,
    [switch]$NoDebug,
    [switch]$NoRelease
)

$MACOS_OUTPUT_FOLDER = "macos"
$IOS_OUTPUT_FOLDER = "ios"
$IOS_SIMULATOR_OUTPUT_FOLDER = "ios_simulator"

function BuildProject($path)
{
    Write-Host "Build XCode Project"
    Push-Location "$path"
    try
    {
        if (!$NoDebug)
        {
            cmake --build . --target lib3MF_s --config Debug
        }
        if (!$NoRelease)
        {
            cmake --build . --target lib3MF_s --config Release
        }
    }
    finally
    {
        Pop-Location
    }
}

function GenerateNuGetMacOS()
{
    nuget pack $PSScriptRoot/../build/macos/nuget/macos/lib3mf.macos.nuspec -OutputDirectory $PSScriptRoot/../build/nuget
}

function GenerateNuGetIOS()
{
    nuget pack $PSScriptRoot/../build/ios/nuget/ios/lib3mf.ios.nuspec -OutputDirectory $PSScriptRoot/../build/nuget
}

function Main()
{
    if (!$NoMacOS)
    {
        BuildProject $PSScriptRoot/../build/$MACOS_OUTPUT_FOLDER
    }

    if (!$NoIOS)
    {
        BuildProject $PSScriptRoot/../build/$IOS_OUTPUT_FOLDER
    }

    if (!$NoSimulator)
    {
        BuildProject $PSScriptRoot/../build/$IOS_SIMULATOR_OUTPUT_FOLDER
    }

    if (!$NoNuGet)
    {
        if (!$NoMacOS)
        {
            GenerateNuGetMacOS
        }

        # Only generate the iOS NuGet package if we built both IOS and Simulator
        if (!$NoIOS -and !$NoSimulator)
        {
            GenerateNuGetIOS
        }
    }
    
}

Main