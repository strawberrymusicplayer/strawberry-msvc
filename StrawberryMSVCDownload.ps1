#Requires -Version 5.1

<#
.SYNOPSIS
  Downloads dependencies and clones repositories for Strawberry MSVC build
.DESCRIPTION
  This script downloads all required dependencies and clones necessary Git repositories
  for building Strawberry Music Player and its dependencies on Windows with MSVC.
.PARAMETER DownloadsPath
  Path where downloads will be stored (default: c:\data\projects\strawberry\msvc_\downloads)
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [string]$downloads_path = "c:\data\projects\strawberry\msvc_\downloads"
)

$ErrorActionPreference = "Stop"

# Load version information
$script_path = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$script_path\versions.ps1"

# Import common functions
Import-Module "$script_path\StrawberryMSVCBuildFunctions.psm1" -Force

Write-Host "Strawberry MSVC Dependencies Download Script" -ForegroundColor Green
Write-Host "Downloads path: $downloads_path" -ForegroundColor Cyan
Write-Host ""

# Setup
Set-Location C:\
if (-not (Test-Path $downloads_path)) {
  New-Item -ItemType Directory -Path $downloads_path -Force | Out-Null
}
Set-Location $downloads_path

# Check for curl
if (-not (Test-Command "curl")) {
  throw "Missing curl."
}

# Install Git if needed
if (-not (Test-Path "C:\Program Files\Git\bin\git.exe")) {
  Write-Host "Installing git..." -ForegroundColor Yellow
  $gitInstaller = Join-Path $downloads_path "Git-$git_version-64-bit.exe"
  if (Test-Path $gitInstaller) {
    Start-Process -FilePath $gitInstaller -ArgumentList "/silent /norestart" -Wait -NoNewWindow
  }
}

# Check for git
$null = Get-Command git -ErrorAction SilentlyContinue
if (-not $?) {
  $env:PATH = "C:\Program Files\Git\bin;$env:PATH"
}

if (-not (Test-Command "git")) {
  throw "Missing git."
}

# Use the common download function
Invoke-DependencyDownload -DownloadsPath $downloads_path

Write-Host "`nDownload completed!" -ForegroundColor Green
