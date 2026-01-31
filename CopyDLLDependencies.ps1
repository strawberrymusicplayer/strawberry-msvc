# CopyDLLDependencies.ps1
# Copyright 2025-2026, Jonas Kvinge <jonas@jkvinge.net>
#
# Strawberry is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Strawberry is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Strawberry.  If not, see <http://www.gnu.org/licenses/>.
#

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Copy = $false
$DestDir = ""
$InDirs = @()
$RecursiveSrcDirs = @()

for ($i = 0; $i -lt $args.Count; $i++) {
  switch ($args[$i]) {
    "-Copy" {
      $Copy = $true
    }

    "-DestDir" {
      $i++
      $DestDir = $args[$i]
    }

    "-InDir" {
      $i++
      $InDirs += $args[$i]
    }

    "-F" {
      $i++
      $InDirs += $args[$i]
    }

    "-RecursiveSrcDir" {
      $i++
      $RecursiveSrcDirs += $args[$i]
    }

    default {
      throw "Unknown argument: $($args[$i])"
    }
  }
}

if (-not $DestDir) {
  throw "Missing -DestDir"
}
if ($InDirs.Count -eq 0) {
  throw "No -InDir specified"
}
if ($RecursiveSrcDirs.Count -eq 0) {
  throw "No -RecursiveSrcDir specified"
}

$DestDir = (Resolve-Path $DestDir).Path
$InDirs = $InDirs | ForEach-Object { (Resolve-Path $_).Path }
$RecursiveSrcDirs = $RecursiveSrcDirs | ForEach-Object { (Resolve-Path $_).Path }

$UsePeLdd = $false

if (Get-Command peldd -ErrorAction SilentlyContinue) {
  Write-Host "Using peldd"
  $UsePeLdd = $true
}
elseif (-not (Get-Command dumpbin -ErrorAction SilentlyContinue)) {
  throw "Neither peldd nor dumpbin found"
}

function Get-DllDependencies {
  param (
    [string]$BinaryPath
  )

  if ($UsePeLdd) {
    return & peldd $BinaryPath |
      ForEach-Object { $_.Trim() } |
      Where-Object { $_ -match '\.dll$' }
  }

  $Dependencies = @()
  $Capture = $false

  & dumpbin /DEPENDENTS $BinaryPath 2>$null | ForEach-Object {
    if ($_ -match "Image has the following dependencies") {
      $Capture = $true
      return
    }

    if ($Capture -and ($_ -match '\.dll$')) {
      $Dependencies += $_.Trim()
    }
  }

  return $Dependencies
}

function Resolve-BinaryPath {
  param (
    [string]$Name
  )

  if ([System.IO.Path]::IsPathRooted($Name)) {
    if (Test-Path $Name) {
      return (Resolve-Path $Name).Path
    }
    return $null
  }

  foreach ($RecursiveSrcDir in $RecursiveSrcDirs) {
    $FilePath = Join-Path $RecursiveSrcDir $Name
    if (Test-Path $FilePath) {
      return (Resolve-Path $FilePath).Path
    }
  }

  return $null
}

$DependenciesSeen = @{}
$DependenciesCopied = @{}
$DependenciesQueue = New-Object System.Collections.Queue

foreach ($InDir in $InDirs) {
  Get-ChildItem $InDir -Recurse -File |
    Where-Object { $_.Extension -in ".dll", ".exe" } |
    ForEach-Object {
      $name = $_.Name.ToLower()
      if (-not $DependenciesSeen.ContainsKey($name)) {
        $DependenciesSeen[$name] = $true
        $DependenciesQueue.Enqueue($_.FullName)
        Write-Host "Seed: $($_.FullName)"
      }
    }
}

while ($DependenciesQueue.Count -gt 0) {
  $DependencyItem = $DependenciesQueue.Dequeue()
  $ResolvedDependency = Resolve-BinaryPath $DependencyItem

  if (-not $ResolvedDependency) {
    Write-Warning "Missing binary: $DependencyItem"
    continue
  }

  Write-Host "Analyzing: $ResolvedDependency"

  $FileName = ([IO.Path]::GetFileName($ResolvedDependency)).ToLower()
  $DestFilePath = Join-Path $DestDir ([IO.Path]::GetFileName($ResolvedDependency))

  if (-not $DependenciesCopied.ContainsKey($FileName)) {
    if (Test-Path $DestFilePath) {
      Write-Host "SKIP (exists): $FileName"
    }
    else {
      Write-Host "COPY: $ResolvedDependency"
      if ($Copy) {
        Copy-Item $ResolvedDependency $DestFilePath -Force
      }
    }
    $DependenciesCopied[$FileName] = $true
  }

  foreach ($Dependency in Get-DllDependencies $ResolvedDependency) {
    $Dependency = $Dependency.ToLower()
    if (-not $DependenciesSeen.ContainsKey($Dependency)) {
      $DependenciesSeen[$Dependency] = $true
      $DependenciesQueue.Enqueue($Dependency)
      Write-Host "  requires: $Dependency"
    }
  }
}

Write-Host "Done."
