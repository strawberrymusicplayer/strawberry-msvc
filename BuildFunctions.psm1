# BuildFunctions.psm1
# Common functions for building dependencies with CMake, Meson, and MSBuild

<#
.SYNOPSIS
  Invokes a CMake build for a project
.PARAMETER SourcePath
  Path to the source directory
.PARAMETER BuildPath
  Path to the build directory
.PARAMETER Generator
  CMake generator to use (default: Ninja)
.PARAMETER BuildType
  Build type (Debug or Release)
.PARAMETER InstallPrefix
  Installation prefix path
.PARAMETER AdditionalArgs
  Additional CMake arguments
#>
function Invoke-CMakeBuild {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,
        
    [Parameter(Mandatory=$true)]
    [string]$BuildPath,
        
    [Parameter(Mandatory=$false)]
    [string]$Generator = "Ninja",
        
    [Parameter(Mandatory=$true)]
    [string]$BuildType,
        
    [Parameter(Mandatory=$true)]
    [string]$InstallPrefix,
        
    [Parameter(Mandatory=$false)]
    [string[]]$AdditionalArgs = @()
  )
    
  Write-Host "Building with CMake: $SourcePath" -ForegroundColor Cyan
    
  if (-not (Test-Path $BuildPath)) {
    New-Item -ItemType Directory -Path $BuildPath -Force | Out-Null
  }
    
  $configureArgs = @(
    "--log-level=DEBUG",
    "-S", $SourcePath,
    "-B", $BuildPath,
    "-G", $Generator,
    "-DCMAKE_BUILD_TYPE=$BuildType",
    "-DCMAKE_INSTALL_PREFIX=$InstallPrefix"
  )
    
  if ($AdditionalArgs) {
    $configureArgs += $AdditionalArgs
  }
    
  & cmake @configureArgs
  if ($LASTEXITCODE -ne 0) {
    throw "CMake configuration failed"
  }
    
  Push-Location $BuildPath
  try {
    & cmake --build .
    if ($LASTEXITCODE -ne 0) {
      throw "CMake build failed"
    }
        
    & cmake --install .
    if ($LASTEXITCODE -ne 0) {
      throw "CMake install failed"
    }
  }
  finally {
    Pop-Location
  }
}

<#
.SYNOPSIS
  Invokes a Meson build for a project
.PARAMETER SourcePath
  Path to the source directory
.PARAMETER BuildPath
  Path to the build directory
.PARAMETER BuildType
  Build type (debug or release)
.PARAMETER InstallPrefix
  Installation prefix path
.PARAMETER PkgConfigPath
  Path to pkg-config files
.PARAMETER AdditionalArgs
  Additional Meson setup arguments
#>
function Invoke-MesonBuild {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,
        
    [Parameter(Mandatory=$true)]
    [string]$BuildPath,
        
    [Parameter(Mandatory=$true)]
    [string]$BuildType,
        
    [Parameter(Mandatory=$true)]
    [string]$InstallPrefix,
        
    [Parameter(Mandatory=$false)]
    [string]$PkgConfigPath,
        
    [Parameter(Mandatory=$false)]
    [string[]]$AdditionalArgs = @()
  )
    
  Write-Host "Building with Meson: $SourcePath" -ForegroundColor Cyan
    
  Push-Location $SourcePath
  try {
    if (-not (Test-Path "$BuildPath\build.ninja")) {
      $setupArgs = @(
        "setup",
        "--buildtype=$BuildType",
        "--default-library=shared",
        "--prefix=$InstallPrefix",
        "--wrap-mode=nodownload"
      )
            
      if ($PkgConfigPath) {
        $setupArgs += "--pkg-config-path=$PkgConfigPath"
      }
            
      if ($AdditionalArgs) {
        $setupArgs += $AdditionalArgs
      }
            
      $setupArgs += $BuildPath
            
      & meson @setupArgs
      if ($LASTEXITCODE -ne 0) {
        throw "Meson setup failed"
      }
    }
        
    Push-Location $BuildPath
    try {
      & ninja
      if ($LASTEXITCODE -ne 0) {
        throw "Ninja build failed"
      }
            
      & ninja install
      if ($LASTEXITCODE -ne 0) {
        throw "Ninja install failed"
      }
    }
    finally {
      Pop-Location
    }
  }
  finally {
    Pop-Location
  }
}

<#
.SYNOPSIS
  Invokes an MSBuild for a project
.PARAMETER ProjectPath
  Path to the solution or project file
.PARAMETER Configuration
  Build configuration (Debug or Release)
.PARAMETER Platform
  Build platform (default: x64)
.PARAMETER AdditionalArgs
  Additional MSBuild arguments
#>
function Invoke-MSBuildProject {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,
        
    [Parameter(Mandatory=$true)]
    [string]$Configuration,
        
    [Parameter(Mandatory=$false)]
    [string]$Platform = "x64",
        
    [Parameter(Mandatory=$false)]
    [string[]]$AdditionalArgs = @()
  )
    
  Write-Host "Building with MSBuild: $ProjectPath" -ForegroundColor Cyan
    
  $buildArgs = @(
    $ProjectPath,
    "/p:Configuration=$Configuration"
  )
    
  if ($Platform) {
    $buildArgs += "/p:Platform=$Platform"
  }
    
  if ($AdditionalArgs) {
    $buildArgs += $AdditionalArgs
  }
    
  & msbuild @buildArgs
  if ($LASTEXITCODE -ne 0) {
    throw "MSBuild failed"
  }
}

<#
.SYNOPSIS
  Upgrades a Visual Studio project file
.PARAMETER ProjectPath
  Path to the project file
#>
function Update-VSProject {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
  )
    
  Write-Host "Upgrading Visual Studio project: $ProjectPath" -ForegroundColor Cyan
    
  $devenvPath = & "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.com" 2>&1
  if ($LASTEXITCODE -ne 0) {
    $devenvPath = & "${env:ProgramFiles}\Microsoft Visual Studio\2026\Community\Common7\IDE\devenv.com" 2>&1
  }
    
  Start-Process -FilePath "devenv.exe" -ArgumentList "$ProjectPath /upgrade" -Wait -NoNewWindow
}

<#
.SYNOPSIS
  Downloads a file if it doesn't already exist
.PARAMETER Url
  URL to download from
.PARAMETER DestinationPath
  Path to save the file
#>
function Get-FileIfNotExists {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$Url,
        
    [Parameter(Mandatory=$true)]
    [string]$DestinationPath
  )
    
  $fileName = Split-Path $Url -Leaf
  $filePath = Join-Path $DestinationPath $fileName
    
  if (-not (Test-Path $filePath)) {
    Write-Host "Downloading $fileName" -ForegroundColor Yellow
    try {
      Invoke-WebRequest -Uri $Url -OutFile $filePath -UseBasicParsing
    }
    catch {
      Write-Error "Failed to download $Url : $_"
      throw
    }
  }
}

<#
.SYNOPSIS
  Clones or updates a Git repository
.PARAMETER Url
  Git repository URL
.PARAMETER DestinationPath
  Path to clone to
#>
function Sync-GitRepository {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$Url,
        
    [Parameter(Mandatory=$true)]
    [string]$DestinationPath
  )
    
  $repoName = Split-Path $Url -Leaf
  $repoPath = Join-Path $DestinationPath $repoName
    
  if (Test-Path $repoPath) {
    Write-Host "Updating repository $Url" -ForegroundColor Yellow
    Push-Location $repoPath
    try {
      & git pull --rebase
      if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to update repository $Url"
      }
    }
    finally {
      Pop-Location
    }
  }
  else {
    Write-Host "Cloning repository $Url" -ForegroundColor Yellow
    & git clone --recurse-submodules $Url $repoPath
    if ($LASTEXITCODE -ne 0) {
      throw "Failed to clone repository $Url"
    }
  }
}

<#
.SYNOPSIS
  Extracts a compressed archive
.PARAMETER ArchivePath
  Path to the archive file
.PARAMETER DestinationPath
  Path to extract to
#>
function Expand-Archive7Zip {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$ArchivePath,
        
    [Parameter(Mandatory=$true)]
    [string]$DestinationPath
  )
    
  if (-not (Test-Path $ArchivePath)) {
    throw "Archive not found: $ArchivePath"
  }
    
  & 7z x -aoa $ArchivePath -o"$DestinationPath"
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to extract archive: $ArchivePath"
  }
}

<#
.SYNOPSIS
  Tests if a command exists
.PARAMETER Command
  Command name to test
#>
function Test-Command {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$Command
  )
    
  $null = Get-Command $Command -ErrorAction SilentlyContinue
  return $?
}

<#
.SYNOPSIS
  Ensures a command is available in PATH
.PARAMETER Command
  Command name to check
.PARAMETER Path
  Path to add to PATH if command is not found
.PARAMETER ErrorMessage
  Error message to display if command is not found
#>
function Assert-Command {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$Command,
        
    [Parameter(Mandatory=$false)]
    [string]$Path,
        
    [Parameter(Mandatory=$true)]
    [string]$ErrorMessage
  )
    
  if (-not (Test-Command $Command)) {
    if ($Path -and (Test-Path $Path)) {
      $env:PATH = "$Path;$env:PATH"
    }
        
    if (-not (Test-Command $Command)) {
      throw $ErrorMessage
    }
  }
}

<#
.SYNOPSIS
  Creates a pkg-config .pc file
.PARAMETER Name
  Package name
.PARAMETER Description
  Package description
.PARAMETER Version
  Package version
.PARAMETER Prefix
  Installation prefix
.PARAMETER Libs
  Library flags
.PARAMETER Cflags
  Compiler flags
.PARAMETER Requires
  Required packages
.PARAMETER OutputPath
  Path to save the .pc file
#>
function New-PkgConfigFile {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$Name,
        
    [Parameter(Mandatory=$true)]
    [string]$Description,
        
    [Parameter(Mandatory=$true)]
    [string]$Version,
        
    [Parameter(Mandatory=$true)]
    [string]$Prefix,
        
    [Parameter(Mandatory=$true)]
    [string]$Libs,
        
    [Parameter(Mandatory=$false)]
    [string]$Cflags = "",
        
    [Parameter(Mandatory=$false)]
    [string]$Requires = "",
        
    [Parameter(Mandatory=$true)]
    [string]$OutputPath
  )
    
  $content = @"
prefix=$Prefix
exec_prefix=`${prefix}
libdir=`${exec_prefix}/lib
includedir=`${prefix}/include

Name: $Name
Description: $Description
Version: $Version
"@
    
  if ($Requires) {
    $content += "`nRequires: $Requires"
  }
    
  $content += "`nLibs: -L`${libdir} $Libs"
    
  if ($Cflags) {
    $content += "`nCflags: $Cflags"
  }
    
  Set-Content -Path $OutputPath -Value $content -Encoding ASCII
}

Export-ModuleMember -Function @(
  'Invoke-CMakeBuild',
  'Invoke-MesonBuild',
  'Invoke-MSBuildProject',
  'Update-VSProject',
  'Get-FileIfNotExists',
  'Sync-GitRepository',
  'Expand-Archive7Zip',
  'Test-Command',
  'Assert-Command',
  'New-PkgConfigFile'
)
