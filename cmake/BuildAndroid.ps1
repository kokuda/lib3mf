<#
/**************************************************************
*                                                             *
#  Copyright (c) Microsoft Corporation. All rights reserved.  *
#               Licensed under the MIT License.               *
*                                                             *
**************************************************************/
.SYNOPSIS
Invokes CMake to build Canvas3d for android targets.

.DESCRIPTION
It first creates ninja files as native build target. Then invokes ninja to kick off
actual build process.
Assumes, CMake, ninja and Android-ndk are available.

.EXAMPLE
androidbuild.ps1 -arm64
#>

[CmdletBinding()]
param(
    [switch]$Clean,
    [switch]$Rebuild,
    [switch]$arm64,
    [switch]$arm32,
    [switch]$x86,
    [switch]$x86_64,
    [switch]$NoDebug
)

$ErrorActionPreference = "stop"
if($NoDebug) {$BuildType = "Release"} else { $BuildType = "Debug"}

function GenerateNinjaFiles()
{
    $AndroidABI = findABI
    $BuildDirName = getBuildDirName
    Write-Host "Generating Android ninja files for $AndroidABI"
    New-Item -Path "$PSScriptRoot\..\build" -Name $BuildDirName -ItemType Directory -Force | Out-Null
	New-Item -Path "$PSScriptRoot\..\build\$BuildDirName" -Name $BuildType -ItemType Directory -Force | Out-Null
    Push-Location "$PSScriptRoot\..\build\$BuildDirName\$BuildType" | Out-Null

    try
    {
        if (Test-Path Env:ANDROID_HOME)
        {
            $AndroidNDKRoot = "$Env:ANDROID_HOME\ndk-bundle"
        }
        else
        {
            $Appdata = [Environment]::GetFolderPath('ApplicationData')
            $AndroidNDKRoot = "$Appdata\..\Local\Android\Sdk\ndk-bundle"
        }
        $AndroidToolChain = "$AndroidNDKRoot\build\cmake\android.toolchain.cmake"
        $AndroidPlatform = "android-21"

        # A path with back-slash as separator can be passed to cmake via commandline but cannot be used in any cmake file.
        # So, to avoid any confusion changing path separator to forward slash.
        $AndroidToolChain = $AndroidToolChain -replace "\\", "/"
        cmake ..\..\.. -DANDROID_ABI="$AndroidABI" -DANDROID_PLATFORM="$AndroidPlatform" -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=intermediates -DCMAKE_BUILD_TYPE="$BuildType" -DCMAKE_TOOLCHAIN_FILE="$AndroidToolChain" -DCMAKE_CXX_FLAGS="-fexceptions -DGTEST_HAS_STD_WSTRING" -DANDROID_STL=c++_static -GNinja -DANDROID_OS_PLATFORM=ANDROID -DLIB3MF_TESTS=TRUE | Write-Host
    }
    finally
    {
        Pop-Location | Out-Null
    }
}

function BuildTarget()
{
    $BuildDirName = getBuildDirName
    Push-Location "$PSScriptRoot\..\build\$BuildDirName\$BuildType" | Out-Null
    try
    {
        cmake --build . --config "$BuildType" | Write-Host
    }
    finally
    {
        Pop-Location | Out-Null
    }
}

function cleanAllTargets()
{
    Remove-Item "$PSScriptRoot\Built" -Recurse -Force -ErrorAction Ignore | Write-Host
}

function cleanTarget()
{
    # Delete both compilation and installation directories.
    $BuildDirName = getBuildDirName
    Remove-Item "$PSScriptRoot\build\$BuildDirName\$BuildType" -Recurse -Force -ErrorAction Ignore | Write-Host
}

function findABI()
{
    $ABI = "x86"
    if($arm32)
    {
        $ABI = "armeabi-v7a"
    }
    elseif($arm64)
    {
        $ABI = "arm64-v8a"
    }
    elseif($x86_64)
    {
        $abi = "x86_64"
    }
    return $ABI
}

function getBuildDirName()
{
    $AndroidABI = findABI
    $BuildDirName = "android_$AndroidABI"
    return $BuildDirName
}

function Main()
{
    if($Clean)
    {
        cleanTarget
    }
    else
    {
        if($Rebuild)
        {
            cleanTarget
        }

        GenerateNinjaFiles
        BuildTarget
    }
}

Main
