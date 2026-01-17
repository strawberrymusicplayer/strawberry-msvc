#Requires -Version 5.1

<#
.SYNOPSIS
  Installs build tools and dependencies for Strawberry MSVC build
.DESCRIPTION
  This script installs required build tools from the downloads directory.
  Tools are only installed if they are not already present.
.PARAMETER DownloadsPath
  Path where downloads are stored (default: c:\data\projects\strawberry\msvc_\downloads)
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

Write-Host "Strawberry MSVC Build Tools Installation Script" -ForegroundColor Green
Write-Host ""

function Test-Command {
  param([string]$Command)
    
  $null = Get-Command $Command -ErrorAction SilentlyContinue
  return $?
}

function Get-ToolVersion {
  param(
    [string]$tool_path,
    [string]$version_arg = "--version"
  )
    
  try {
    $output = & $tool_path $version_arg 2>&1 | Out-String
    return $output.Trim()
  }
  catch {
    return $null
  }
}

function Test-ToolVersionMatch {
  param(
    [string]$installed_version,
    [string]$expected_version
  )
    
  # Extract version numbers using regex
  if ($installed_version -match '(\d+\.[\d\.]+)') {
    $installed_ver = $matches[1]
  }
  else {
    return $false
  }
    
  # Compare versions
  return $installed_ver -like "$expected_version*"
}

function Test-ToolInstalled {
  param(
    [string]$path,
    [string]$name,
    [string]$expected_version = $null,
    [string]$version_arg = "--version"
  )
    
  if (Test-Path $path) {
    if ($expected_version) {
      # Check version if expected version is provided
      $installed_version = Get-ToolVersion -ToolPath $path -VersionArg $version_arg
      if ($installed_version) {
        if (Test-ToolVersionMatch -InstalledVersion $installed_version -ExpectedVersion $expected_version) {
          Write-Host "✓ $name is already installed (version matches: $expected_version)" -ForegroundColor Green
          return $true
        }
        else {
          Write-Host "⚠ $name is installed but version doesn't match (installed: $installed_version, expected: $expected_version)" -ForegroundColor Yellow
          Write-Host "  Will reinstall to update to version $expected_version" -ForegroundColor Yellow
          return $false
        }
      }
      else {
        # Could not determine version, assume it needs reinstall
        Write-Host "⚠ $name is installed but version could not be determined" -ForegroundColor Yellow
        Write-Host "  Will reinstall to ensure version $expected_version" -ForegroundColor Yellow
        return $false
      }
    }
    else {
      # No version check needed
      Write-Host "✓ $name is already installed" -ForegroundColor Green
      return $true
    }
  }
  return $false
}

function Install-Tool {
  param(
    [string]$installer_path,
    [string[]]$arguments,
    [string]$name
  )
    
  Write-Host "Installing $name..." -ForegroundColor Yellow
    
  if (-not (Test-Path $installer_path)) {
    Write-Error "Installer not found: $installer_path"
    return $false
  }
    
  try {
    Start-Process -FilePath $installer_path -ArgumentList $arguments -Wait -NoNewWindow
    Write-Host "✓ $name installed successfully" -ForegroundColor Green
    return $true
  }
  catch {
    Write-Error "Failed to install $name : $_"
    return $false
  }
}

# Check and install Git
if (-not (Test-ToolInstalled -Path "C:\Program Files\Git\bin\git.exe" -Name "Git" -ExpectedVersion $git_version)) {
  $installer = Join-Path $downloads_path "Git-$git_version-64-bit.exe"
  Install-Tool -InstallerPath $installer -Arguments @("/silent", "/norestart") -Name "Git"
}

# Check and install CMake
if (-not (Test-ToolInstalled -Path "C:\Program Files\CMake\bin\cmake.exe" -Name "CMake" -ExpectedVersion $cmake_version)) {
  $installer = Join-Path $downloads_path "cmake-$cmake_version-windows-x86_64.msi"
  Install-Tool -InstallerPath $installer -Arguments @("/quiet", "/norestart") -Name "CMake"
}

# Check and install NASM
if (-not (Test-ToolInstalled -Path "C:\Program Files\nasm\nasm.exe" -Name "NASM" -ExpectedVersion $nasm_version -VersionArg "-v")) {
  $installer = Join-Path $downloads_path "nasm-$nasm_version-installer-x64.exe"
  Install-Tool -InstallerPath $installer -Arguments @("/S") -Name "NASM"
}

# Check and install 7-Zip
# Note: 7-Zip doesn't have a reliable version check via command line
if (-not (Test-ToolInstalled -Path "C:\Program Files\7-Zip\7z.exe" -Name "7-Zip")) {
  $installer = Join-Path $downloads_path "7z$_7zip_version-x64.exe"
  Install-Tool -InstallerPath $installer -Arguments @("/S") -Name "7-Zip"
}

# Check and install Strawberry Perl
# Note: Checking Perl version requires execution which may not work in all contexts
if (-not (Test-ToolInstalled -Path "C:\Strawberry\perl\bin\perl.exe" -Name "Strawberry Perl" -ExpectedVersion $strawberry_perl_version -VersionArg "-v")) {
  $installer = Join-Path $downloads_path "strawberry-perl-$strawberry_perl_version-64bit.msi"
  Install-Tool -InstallerPath $installer -Arguments @("/quiet", "/norestart") -Name "Strawberry Perl"
}

# Check and install Python
# Note: Python may install to different paths depending on version
$python_paths = @(
  "C:\Program Files\Python314\python.exe",
  "C:\Program Files\Python313\python.exe",
  "C:\Program Files\Python312\python.exe",
  "C:\Program Files\Python311\python.exe",
  "C:\Program Files\Python310\python.exe"
)

$python_installed = $false
foreach ($python_path in $python_paths) {
  if (Test-Path $python_path) {
    # Check Python version
    $installed_version = Get-ToolVersion -ToolPath $python_path
    if ($installed_version -and $installed_version -match '(\d+\.\d+\.\d+)') {
      $installed_ver = $matches[1]
      if ($installed_ver -like "$python_version*") {
        Write-Host "✓ Python is already installed at $python_path (version matches: $python_version)" -ForegroundColor Green
        $python_installed = $true
        break
      }
      else {
        Write-Host "⚠ Python $installed_ver is installed at $python_path but expected version is $python_version" -ForegroundColor Yellow
        Write-Host "  Will install the expected version" -ForegroundColor Yellow
      }
    }
    else {
      Write-Host "⚠ Python is installed at $python_path but version could not be determined" -ForegroundColor Yellow
    }
  }
}

if (-not $python_installed) {
  $installer = Join-Path $downloads_path "python-$python_version-amd64.exe"
  Install-Tool -InstallerPath $installer -Arguments @("/quiet", "InstallAllUsers=1", "PrependPath=1", "Include_test=0") -Name "Python"
}

# Check and install Win Flex Bison
if (-not (Test-ToolInstalled -Path "C:\win_flex_bison\win_bison.exe" -Name "Win Flex Bison")) {
  Write-Host "Installing Win Flex Bison..." -ForegroundColor Yellow
    
  Set-Location C:\
  if (-not (Test-Path "win_flex_bison")) {
    New-Item -ItemType Directory -Path "win_flex_bison" -Force | Out-Null
  }
  Set-Location "win_flex_bison"
    
  # Ensure 7z is in PATH
  if (-not (Test-Command "7z")) {
    $env:PATH = "C:\Program Files\7-Zip;$env:PATH"
  }
    
  $archive = Join-Path $downloads_path "win_flex_bison-$winflexbison_version.zip"
  & "C:\Program Files\7-Zip\7z.exe" x -aoa $archive
    
  if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Win Flex Bison installed successfully" -ForegroundColor Green
  }
}

# Check and install VSYASM
if (-not (Test-ToolInstalled -Path "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\yasm.exe" -Name "VSYASM")) {
  Write-Host "Installing VSYASM..." -ForegroundColor Yellow
    
  $vsyasm_dir = Join-Path $downloads_path "vsyasm"
  if (-not (Test-Path $vsyasm_dir)) {
    New-Item -ItemType Directory -Path $vsyasm_dir -Force | Out-Null
  }
    
  Set-Location $vsyasm_dir
    
  $vsyasm_archive = Join-Path $downloads_path "VSYASM\vsyasm.zip"
  if (Test-Path $vsyasm_archive) {
    & "C:\Program Files\7-Zip\7z.exe" x -aoa $vsyasm_archive
        
    $install_script = Join-Path $vsyasm_dir "install_script.bat"
    if (Test-Path $install_script) {
      Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $install_script -Wait -NoNewWindow
      Write-Host "✓ VSYASM installed successfully" -ForegroundColor Green
    }
  }
  else {
    Write-Warning "VSYASM archive not found. Please install manually."
    Write-Host "  1. Clone https://github.com/ShiftMediaProject/VSYASM" -ForegroundColor Yellow
    Write-Host "  2. Run install_script.bat" -ForegroundColor Yellow
  }
}

Write-Host "`n" -NoNewline
Write-Host "Installation Summary:" -ForegroundColor Cyan
Write-Host "--------------------" -ForegroundColor Cyan

# Verify installations
$tools = @(
  @{ Name = "Git"; Command = "git"; Path = "C:\Program Files\Git\bin" },
  @{ Name = "CMake"; Command = "cmake"; Path = "C:\Program Files\CMake\bin" },
  @{ Name = "NASM"; Command = "nasm"; Path = "C:\Program Files\nasm" },
  @{ Name = "7-Zip"; Command = "7z"; Path = "C:\Program Files\7-Zip" },
  @{ Name = "Perl"; Command = "perl"; Path = "C:\Strawberry\perl\bin" },
  @{ Name = "Python"; Command = "python"; Paths = @("C:\Program Files\Python314", "C:\Program Files\Python313", "C:\Program Files\Python312", "C:\Program Files\Python311", "C:\Program Files\Python310") },
  @{ Name = "Win Flex"; Command = "win_flex"; Path = "C:\win_flex_bison" },
  @{ Name = "Win Bison"; Command = "win_bison"; Path = "C:\win_flex_bison" }
)

foreach ($tool in $tools) {
  # Temporarily add path to check
  $original_path = $env:PATH
    
  if ($tool.Paths) {
    # Python has multiple possible paths
    $found = $false
    foreach ($path in $tool.Paths) {
      $env:PATH = "$path;$env:PATH"
      if (Test-Command $tool.Command) {
        Write-Host "✓ $($tool.Name) is available" -ForegroundColor Green
        $found = $true
        break
      }
      $env:PATH = $original_path
    }
    if (-not $found) {
      Write-Host "✗ $($tool.Name) is NOT available" -ForegroundColor Red
    }
  }
  else {
    $env:PATH = "$($tool.Path);$env:PATH"
        
    if (Test-Command $tool.Command) {
      Write-Host "✓ $($tool.Name) is available" -ForegroundColor Green
    }
    else {
      Write-Host "✗ $($tool.Name) is NOT available" -ForegroundColor Red
    }
        
    $env:PATH = $original_path
  }
}

Write-Host "`nIMPORTANT: Next Steps" -ForegroundColor Cyan
Write-Host "---------------------" -ForegroundColor Cyan
Write-Host "1. Delete pkg-config files from Strawberry Perl to prevent conflicts:" -ForegroundColor Yellow
Write-Host "   - C:\strawberry\perl\bin\pkg-config" -ForegroundColor Gray
Write-Host "   - C:\strawberry\perl\bin\pkg-config.bat" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Configure PATH environment variable (System Properties > Environment Variables):" -ForegroundColor Yellow
Write-Host "   - Delete: C:\Strawberry\c\bin" -ForegroundColor Gray
Write-Host "   - Add: C:\Program Files\Git\bin" -ForegroundColor Gray
Write-Host "   - Add: C:\Program Files (x86)\NSIS" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Install Meson via Python PIP (from x64 Native Tools Command Prompt):" -ForegroundColor Yellow
Write-Host "   pip install meson" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Install Rust compiler:" -ForegroundColor Yellow
Write-Host "   - Run: $downloads_path\rustup-init.exe" -ForegroundColor Gray
Write-Host "   - Then run: cargo install cargo-c" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Optionally install NSIS and plugins for creating Windows installer" -ForegroundColor Yellow
Write-Host ""

Write-Host "Installation script completed!" -ForegroundColor Green
