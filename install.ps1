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
    [string]$DownloadsPath = "c:\data\projects\strawberry\msvc_\downloads"
)

$ErrorActionPreference = "Stop"

# Load version information
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptPath\versions.ps1"

Write-Host "Strawberry MSVC Build Tools Installation Script" -ForegroundColor Green
Write-Host ""

function Test-ToolInstalled {
    param(
        [string]$Path,
        [string]$Name
    )
    
    if (Test-Path $Path) {
        Write-Host "✓ $Name is already installed" -ForegroundColor Green
        return $true
    }
    return $false
}

function Install-Tool {
    param(
        [string]$InstallerPath,
        [string[]]$Arguments,
        [string]$Name
    )
    
    Write-Host "Installing $Name..." -ForegroundColor Yellow
    
    if (-not (Test-Path $InstallerPath)) {
        Write-Error "Installer not found: $InstallerPath"
        return $false
    }
    
    try {
        Start-Process -FilePath $InstallerPath -ArgumentList $Arguments -Wait -NoNewWindow
        Write-Host "✓ $Name installed successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to install $Name : $_"
        return $false
    }
}

# Check and install Git
if (-not (Test-ToolInstalled -Path "C:\Program Files\Git\bin\git.exe" -Name "Git")) {
    $installer = Join-Path $DownloadsPath "Git-$GIT_VERSION-64-bit.exe"
    Install-Tool -InstallerPath $installer -Arguments @("/silent", "/norestart") -Name "Git"
}

# Check and install CMake
if (-not (Test-ToolInstalled -Path "C:\Program Files\CMake\bin\cmake.exe" -Name "CMake")) {
    $installer = Join-Path $DownloadsPath "cmake-$CMAKE_VERSION-windows-x86_64.msi"
    Install-Tool -InstallerPath $installer -Arguments @("/quiet", "/norestart") -Name "CMake"
}

# Check and install NASM
if (-not (Test-ToolInstalled -Path "C:\Program Files\nasm\nasm.exe" -Name "NASM")) {
    $installer = Join-Path $DownloadsPath "nasm-$NASM_VERSION-installer-x64.exe"
    Install-Tool -InstallerPath $installer -Arguments @("/S") -Name "NASM"
}

# Check and install 7-Zip
if (-not (Test-ToolInstalled -Path "C:\Program Files\7-Zip\7z.exe" -Name "7-Zip")) {
    $installer = Join-Path $DownloadsPath "7z$_7ZIP_VERSION-x64.exe"
    Install-Tool -InstallerPath $installer -Arguments @("/S") -Name "7-Zip"
}

# Check and install Strawberry Perl
if (-not (Test-ToolInstalled -Path "C:\Strawberry\perl\bin" -Name "Strawberry Perl")) {
    $installer = Join-Path $DownloadsPath "strawberry-perl-$STRAWBERRY_PERL_VERSION-64bit.msi"
    Install-Tool -InstallerPath $installer -Arguments @("/quiet", "/norestart") -Name "Strawberry Perl"
}

# Check and install Python
# Note: Python may install to different paths depending on version
$pythonPaths = @(
    "C:\Program Files\Python314\python.exe",
    "C:\Program Files\Python313\python.exe",
    "C:\Program Files\Python312\python.exe",
    "C:\Program Files\Python311\python.exe",
    "C:\Program Files\Python310\python.exe"
)

$pythonInstalled = $false
foreach ($pythonPath in $pythonPaths) {
    if (Test-Path $pythonPath) {
        Write-Host "✓ Python is already installed at $pythonPath" -ForegroundColor Green
        $pythonInstalled = $true
        break
    }
}

if (-not $pythonInstalled) {
    $installer = Join-Path $DownloadsPath "python-$PYTHON_VERSION-amd64.exe"
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
    
    $archive = Join-Path $DownloadsPath "win_flex_bison-$WINFLEXBISON_VERSION.zip"
    & "C:\Program Files\7-Zip\7z.exe" x -aoa $archive
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Win Flex Bison installed successfully" -ForegroundColor Green
    }
}

# Check and install VSYASM
if (-not (Test-ToolInstalled -Path "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\yasm.exe" -Name "VSYASM")) {
    Write-Host "Installing VSYASM..." -ForegroundColor Yellow
    
    $vsyasmDir = Join-Path $DownloadsPath "vsyasm"
    if (-not (Test-Path $vsyasmDir)) {
        New-Item -ItemType Directory -Path $vsyasmDir -Force | Out-Null
    }
    
    Set-Location $vsyasmDir
    
    $vsyasmArchive = Join-Path $DownloadsPath "VSYASM\vsyasm.zip"
    if (Test-Path $vsyasmArchive) {
        & "C:\Program Files\7-Zip\7z.exe" x -aoa $vsyasmArchive
        
        $installScript = Join-Path $vsyasmDir "install_script.bat"
        if (Test-Path $installScript) {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $installScript -Wait -NoNewWindow
            Write-Host "✓ VSYASM installed successfully" -ForegroundColor Green
        }
    }
    else {
        Write-Warning "VSYASM archive not found. Please install manually."
        Write-Host "  1. Clone https://github.com/ShiftMediaProject/VSYASM" -ForegroundColor Yellow
        Write-Host "  2. Run install_script.bat" -ForegroundColor Yellow
    }
}

function Test-Command {
    param([string]$Command)
    
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
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
    $originalPath = $env:PATH
    
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
            $env:PATH = $originalPath
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
        
        $env:PATH = $originalPath
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
Write-Host "   - Run: $DownloadsPath\rustup-init.exe" -ForegroundColor Gray
Write-Host "   - Then run: cargo install cargo-c" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Optionally install NSIS and plugins for creating Windows installer" -ForegroundColor Yellow
Write-Host ""

Write-Host "Installation script completed!" -ForegroundColor Green
