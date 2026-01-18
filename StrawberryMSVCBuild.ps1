# StrawberryMSVCBuild.ps1
# Strawberry MSVC dependencies build script
# PowerShell version of build.bat

<#
.SYNOPSIS
  Build script for Strawberry MSVC dependencies
.DESCRIPTION
  Builds all dependencies required for Strawberry Music Player on Windows using MSVC
.PARAMETER BuildType
  Build type: debug or release (default: debug)
.EXAMPLE
  .\StrawberryMSVCBuild.ps1 -build_type release
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [ValidateSet("debug", "release")]
  [string]$build_type = "debug"
)

# Set strict mode
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Green
Write-Host "Strawberry MSVC Dependencies Build Script" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Import versions and build functions
try {
  . "$PSScriptRoot\versions.ps1"
  Import-Module "$PSScriptRoot\StrawberryMSVCBuildFunctions.psm1" -Force
} catch {
  Write-Error "Failed to import versions.ps1 or StrawberryMSVCBuildFunctions.psm1: $_"
  exit 1
}

# Set build configuration
if ($build_type -eq "debug") {
  $cmake_build_type = "Debug"
  $meson_build_type = "debug"
  $lib_postfix = "d"
} elseif ($build_type -eq "release") {
  $cmake_build_type = "Release"
  $meson_build_type = "release"
  $lib_postfix = ""
}

# Set paths
$downloads_path = "c:\data\projects\strawberry\msvc_\downloads"
$build_path = "c:\data\projects\strawberry\msvc_\build_$build_type"
$prefix_path = "c:\strawberry_msvc_x86_64_$build_type"
$prefix_path_forward = $prefix_path -replace '\\', '/'
$prefix_path_escape = $prefix_path -replace '\\', '\\'
$qt_dev = "OFF"
$gst_dev = "OFF"

# Set CMake generator
$cmake_generator = "Ninja"

# Display configuration
Write-Host "Build Configuration:" -ForegroundColor Cyan
Write-Host "  Downloads path:      $downloads_path"
Write-Host "  Build path:          $build_path"
Write-Host "  Build type:          $build_type"
Write-Host "  CMake build type:    $cmake_build_type"
Write-Host "  Meson build type:    $meson_build_type"
Write-Host "  Prefix path:         $prefix_path"
Write-Host "  Prefix path forward: $prefix_path_forward"
Write-Host "  Prefix path escape:  $prefix_path_escape"
Write-Host ""

# Create directories
Write-Host "Creating directories..." -ForegroundColor Cyan
try {
  @($downloads_path, $build_path, $prefix_path,
      "$prefix_path\bin", "$prefix_path\lib", "$prefix_path\include") | ForEach-Object {
    if (-not (Test-Path $_)) {
      New-Item -ItemType Directory -Path $_ -Force | Out-Null
      Write-Host "  Created: $_" -ForegroundColor Green
    }
  }
} catch {
  Write-Error "Failed to create directories: $_"
  exit 1
}

# Copy sed.exe if needed
if (-not (Test-Path "$prefix_path\bin\sed.exe")) {
  if (Test-Path "$downloads_path\sed.exe") {
    Copy-Item "$downloads_path\sed.exe" "$prefix_path\bin\" -Force
  }
}

# Setup environment variables
Write-Host "Setting up environment variables..." -ForegroundColor Cyan
$env:PKG_CONFIG_EXECUTABLE = "$prefix_path\bin\pkgconf.exe"
$env:PKG_CONFIG_PATH = "$prefix_path\lib\pkgconfig"
$env:CL = "-MP"
$env:PATH = "$env:PATH;$prefix_path\bin"
$env:YASMPATH = "$prefix_path\bin"

# Ensure Visual Studio x64 tools are used
Write-Host "Checking Visual Studio environment..." -ForegroundColor Cyan
$vs_path = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath 2>$null
if ($vs_path) {
  $vs_dev_shell = Join-Path $vs_path "Common7\Tools\Launch-VsDevShell.ps1"
  if (Test-Path $vs_dev_shell) {
    Write-Host "  Initializing Visual Studio x64 environment..." -ForegroundColor Cyan
    # Import VS environment with x64 architecture
    & $vs_dev_shell -Arch amd64 -HostArch amd64 -SkipAutomaticLocation
    Write-Host "  Visual Studio x64 environment initialized" -ForegroundColor Green
  }
}

# Check for required tools
Write-Host "Checking requirements..." -ForegroundColor Cyan

$tool_checks = @(
  @{ Command = "patch"; Paths = @("C:\Program Files\Git\usr\bin"); Message = "Missing patch" }
  @{ Command = "sed"; Paths = @("C:\Program Files\Git\usr\bin"); Message = "Missing sed" }
  @{ Command = "nasm"; Paths = @("C:\Program Files\nasm"); Message = "Missing nasm. Download from https://www.nasm.us/" }
  @{ Command = "win_flex"; Paths = @("C:\win_flex_bison"); Message = "Missing win_flex. Download from https://sourceforge.net/projects/winflexbison/" }
  @{ Command = "win_bison"; Paths = @("C:\win_flex_bison"); Message = "Missing win_bison. Download from https://sourceforge.net/projects/winflexbison/" }
  @{ Command = "perl"; Paths = @("C:\Strawberry\perl\bin"); Message = "Missing perl. Download Strawberry Perl from https://strawberryperl.com/" }
  @{ Command = "python"; Paths = @("C:\Program Files\Python314", "C:\Program Files\Python313", "C:\Program Files\Python312", "C:\Program Files\Python311", "C:\Program Files\Python310"); Message = "Missing python. Download from https://www.python.org/" }
  @{ Command = "tar"; Paths = @("C:\Program Files\Git\usr\bin"); Message = "Missing tar" }
  @{ Command = "bzip2"; Paths = @("C:\Program Files\Git\usr\bin"); Message = "Missing bzip2" }
  @{ Command = "7z"; Paths = @("C:\Program Files\7-Zip"); Message = "Missing 7z. Download 7-Zip from https://www.7-zip.org/download.html" }
  @{ Command = "cmake"; Paths = @("C:\Program Files\CMake\bin"); Message = "Missing cmake. Download from https://cmake.org/" }
  @{ Command = "meson"; Paths = @("C:\Program Files\Meson"); Message = "Missing meson. Download from https://mesonbuild.com/" }
  @{ Command = "nmake"; Paths = @(); Message = "Missing nmake. Install Visual Studio 2022" }
)

foreach ($check in $tool_checks) {
  if (-not (Test-Command $check.Command)) {
    foreach ($path in $check.Paths) {
      if (Test-Path $path) {
        $env:PATH = "$env:PATH;$path"
        break
      }
    }

    if (-not (Test-Command $check.Command)) {
      Write-Error $check.Message
      exit 1
    }
  }
  Write-Host "  $($check.Command) found" -ForegroundColor Green
}

Write-Host ""
Write-Host "All requirements satisfied!" -ForegroundColor Green
Write-Host ""

#region Build Functions

function Build-Yasm {
  Write-Host "Building yasm" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "yasm")) {
      New-Item -ItemType Directory -Path "yasm" -Force | Out-Null
      Copy-Item "$downloads_path\yasm\*" "yasm\" -Recurse -Force
    }

    Set-Location "yasm"
    & patch -p1 -N -i "$downloads_path\yasm-cmake.patch" 2>&1 | Out-Null

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @("-DBUILD_SHARED_LIBS=ON")
  } finally {
    Pop-Location
  }
}

function Build-Pkgconf {
  Write-Host "Building pkgconf" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    $pkgDir = Get-ChildItem -Directory -Filter "pkgconf-pkgconf-$pkgconf_version" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $pkgDir) {
      $tar_file = "$downloads_path\pkgconf-$pkgconf_version.tar.gz"
      Write-Host "Extracting $tar_file" -ForegroundColor Cyan
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
      if ($LASTEXITCODE -ne 0) {
        throw "Failed to extract pkgconf archive"
      }
      $pkgDir = Get-ChildItem -Directory -Filter "pkgconf-pkgconf-$pkgconf_version" | Select-Object -First 1
    }

    if (-not $pkgDir) {
      throw "Failed to find extracted pkgconf directory"
    }

    Set-Location $pkgDir.FullName

    Invoke-MesonBuild -source_path "." -build_path "build" `
      -build_type $meson_build_type -install_prefix $prefix_path `
      -pkg_config_path "$prefix_path\lib\pkgconfig" `
      -additional_args @("-Dtests=disabled")

    Copy-Item "$prefix_path\bin\pkgconf.exe" "$prefix_path\bin\pkg-config.exe" -Force
  } finally {
    Pop-Location
  }
}

function Build-GetoptWin {
  Write-Host "Building getopt-win" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "getopt-win-$getopt_win_version")) {
      $tar_file = "$downloads_path\getopt-win-$getopt_win_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "getopt-win-$getopt_win_version"

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @(
        "-DBUILD_SHARED_LIBS=ON",
        "-DBUILD_SHARED_LIB=ON",
        "-DBUILD_STATIC_LIBS=OFF",
        "-DBUILD_STATIC_LIB=OFF",
        "-DBUILD_TESTING=OFF"
      )
  } finally {
    Pop-Location
  }
}

function Build-Zlib {
  Write-Host "Building zlib" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "zlib-$zlib_version")) {
      $tar_file = "$downloads_path\zlib-$zlib_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "zlib-$zlib_version"

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @(
        "-DBUILD_SHARED_LIBS=ON",
        "-DBUILD_STATIC_LIBS=OFF"
      )

    Copy-Item "$prefix_path\share\pkgconfig\zlib.pc" "$prefix_path\lib\pkgconfig\" -Force
    (Get-Content "$prefix_path\lib\pkgconfig\zlib.pc") -replace '-lz', "-lzlib$lib_postfix" | Set-Content "$prefix_path\lib\pkgconfig\zlib.pc"

    Copy-Item "$prefix_path\lib\zlib$lib_postfix.lib" "$prefix_path\lib\z.lib" -Force

    Remove-Item "$prefix_path\lib\zlibstatic*.lib" -ErrorAction SilentlyContinue
  } finally {
    Pop-Location
  }
}

function Build-OpenSSL {
  Write-Host "Building openssl" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "openssl-$openssl_version")) {
      $tar_file = "$downloads_path\openssl-$openssl_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "openssl-$openssl_version"

    if ($build_type -eq "debug") {
      & perl Configure VC-WIN64A shared zlib no-capieng no-tests --prefix="$prefix_path" --libdir=lib --openssldir="$prefix_path\ssl" --debug --with-zlib-include="$prefix_path\include" --with-zlib-lib="$prefix_path\lib\zlibd.lib"
    } else {
      & perl Configure VC-WIN64A shared zlib no-capieng no-tests --prefix="$prefix_path" --libdir=lib --openssldir="$prefix_path\ssl" --release --with-zlib-include="$prefix_path\include" --with-zlib-lib="$prefix_path\lib\zlib.lib"
    }

    if ($LASTEXITCODE -ne 0) { throw "OpenSSL configure failed" }

    & nmake
    if ($LASTEXITCODE -ne 0) { throw "OpenSSL build failed" }

    & nmake install_sw
    if ($LASTEXITCODE -ne 0) { throw "OpenSSL install failed" }

    Copy-Item "$prefix_path\lib\libssl.lib" "$prefix_path\lib\ssl.lib" -Force
    Copy-Item "$prefix_path\lib\libcrypto.lib" "$prefix_path\lib\crypto.lib" -Force

    # Create pkg-config files
    New-PkgConfigFile -Name "OpenSSL-libcrypto" -Description "OpenSSL cryptography library" `
      -Version $openssl_version -Prefix $prefix_path_forward `
      -Libs "-lcrypto" -Cflags "-DOPENSSL_LOAD_CONF -I`${includedir}" `
      -OutputPath "$prefix_path\lib\pkgconfig\libcrypto.pc"

    New-PkgConfigFile -Name "OpenSSL-libssl" -Description "Secure Sockets Layer and cryptography libraries" `
      -Version $openssl_version -Prefix $prefix_path_forward `
      -Libs "-lssl" -Cflags "-DOPENSSL_LOAD_CONF -I`${includedir}" `
      -Requires "libcrypto" -OutputPath "$prefix_path\lib\pkgconfig\libssl.pc"

    New-PkgConfigFile -Name "OpenSSL" -Description "Secure Sockets Layer and cryptography libraries and tools" `
      -Version $openssl_version -Prefix $prefix_path_forward `
      -Libs "" -Requires "libssl libcrypto" `
      -OutputPath "$prefix_path\lib\pkgconfig\openssl.pc"
  } finally {
    Pop-Location
  }
}

function Build-GMP {
  Write-Host "Installing gmp" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    $smpBuildPath = "$build_path\ShiftMediaProject\build"
    if (-not (Test-Path $smpBuildPath)) {
      New-Item -ItemType Directory -Path $smpBuildPath -Force | Out-Null
    }

    Set-Location $smpBuildPath

    if (-not (Test-Path "gmp")) {
      New-Item -ItemType Directory -Path "gmp" -Force | Out-Null
      Set-Location "gmp"
      Copy-Item "$downloads_path\gmp\*" "." -Recurse -Force
      & git checkout $gmp_version
      Set-Location ..
    }

    Set-Location "gmp\SMP"

    Update-VSProject -ProjectPath "libgmp.vcxproj"
    Invoke-MSBuildProject -ProjectPath "libgmp.vcxproj" -Configuration "${BuildType}DLL"

    Copy-Item "..\..\..\msvc\lib\x64\gmp$lib_postfix.lib" "$prefix_path\lib\" -Force
    Copy-Item "..\..\..\msvc\bin\x64\gmp$lib_postfix.dll" "$prefix_path\bin\" -Force
    Copy-Item "..\..\..\msvc\include\gmp*.h" "$prefix_path\include\" -Force

    New-PkgConfigFile -Name "gmp" -Description "gmp" -Version $gmp_version `
      -Prefix $prefix_path_forward -Libs "-lgmp$lib_postfix" `
      -Cflags "-I`${includedir}" -OutputPath "$prefix_path\lib\pkgconfig\gmp.pc"
  } finally {
    Pop-Location
  }
}

function Build-Nettle {
  Write-Host "Installing nettle" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    $smpBuildPath = "$build_path\ShiftMediaProject\build"
    if (-not (Test-Path $smpBuildPath)) {
      New-Item -ItemType Directory -Path $smpBuildPath -Force | Out-Null
    }

    Set-Location $smpBuildPath

    if (-not (Test-Path "nettle")) {
      New-Item -ItemType Directory -Path "nettle" -Force | Out-Null
      Set-Location "nettle"
      Copy-Item "$downloads_path\nettle\*" "." -Recurse -Force
      & git checkout "nettle_$nettle_version"
      Set-Location ..
    }

    Set-Location "nettle\SMP"

    Update-VSProject -ProjectPath "libnettle.vcxproj"
    Invoke-MSBuildProject -ProjectPath "libnettle.vcxproj" -Configuration "${BuildType}DLL"

    Copy-Item "..\..\..\msvc\lib\x64\nettle$lib_postfix.lib" "$prefix_path\lib\" -Force
    Copy-Item "..\..\..\msvc\bin\x64\nettle$lib_postfix.dll" "$prefix_path\bin\" -Force

    if (-not (Test-Path "$prefix_path\include\nettle")) {
      New-Item -ItemType Directory -Path "$prefix_path\include\nettle" -Force | Out-Null
    }
    Copy-Item "..\..\..\msvc\include\nettle\*.h" "$prefix_path\include\nettle\" -Force

    Update-VSProject -ProjectPath "libhogweed.vcxproj"
    Invoke-MSBuildProject -ProjectPath "libhogweed.vcxproj" -Configuration "${BuildType}DLL"

    Copy-Item "..\..\..\msvc\lib\x64\hogweed$lib_postfix.lib" "$prefix_path\lib\" -Force
    Copy-Item "..\..\..\msvc\bin\x64\hogweed$lib_postfix.dll" "$prefix_path\bin\" -Force
    Copy-Item "..\..\..\msvc\include\nettle\*.h" "$prefix_path\include\nettle\" -Force

    New-PkgConfigFile -Name "nettle" -Description "nettle" -Version $nettle_version `
      -Prefix $prefix_path_forward -Libs "-lnettle$lib_postfix" `
      -Cflags "-I`${includedir}" -OutputPath "$prefix_path\lib\pkgconfig\nettle.pc"

    New-PkgConfigFile -Name "hogweed" -Description "hogweed" -Version $nettle_version `
      -Prefix $prefix_path_forward -Libs "-lhogweed$lib_postfix" `
      -Cflags "-I`${includedir}" -OutputPath "$prefix_path\lib\pkgconfig\hogweed.pc"
  } finally {
    Pop-Location
  }
}

function Build-GnuTLS {
  Write-Host "Installing gnutls" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    $smpBuildPath = "$build_path\ShiftMediaProject\build"
    if (-not (Test-Path $smpBuildPath)) {
      New-Item -ItemType Directory -Path $smpBuildPath -Force | Out-Null
    }

    Set-Location $smpBuildPath

    if (-not (Test-Path "gnutls")) {
      New-Item -ItemType Directory -Path "gnutls" -Force | Out-Null
      Set-Location "gnutls"
      Copy-Item "$downloads_path\gnutls\*" "." -Recurse -Force
      & git checkout $gnutls_version
      Set-Location ..
    }

    Set-Location "gnutls\SMP"

    # Create inject_zlib.props
    $propsContent = @"
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemDefinitionGroup>
  <ClCompile>
      <AdditionalIncludeDirectories>$prefix_path\include;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
  </ClCompile>
  <Link>
      <AdditionalLibraryDirectories>$prefix_path\lib;%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
  </Link>
  </ItemDefinitionGroup>
</Project>
"@
    Set-Content -Path "$build_path\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props" -Value $propsContent

    Update-VSProject -ProjectPath "libgnutls.sln"

    Invoke-MSBuildProject -ProjectPath "libgnutls.sln" -Configuration "${CMAKE_BUILD_TYPE}DLL" `
      -additional_args @("/p:ForceImportBeforeCppTargets=$build_path\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props")

    Copy-Item "..\..\..\msvc\lib\x64\gnutls$lib_postfix.lib" "$prefix_path\lib\" -Force
    Copy-Item "..\..\..\msvc\bin\x64\gnutls$lib_postfix.dll" "$prefix_path\bin\" -Force

    if (-not (Test-Path "$prefix_path\include\gnutls")) {
      New-Item -ItemType Directory -Path "$prefix_path\include\gnutls" -Force | Out-Null
    }
    Copy-Item "..\..\..\msvc\include\gnutls\*.h" "$prefix_path\include\gnutls\" -Force

    # Workaround: Build static deps version
    & "project_get_dependencies.bat"

    Update-VSProject -ProjectPath "..\..\gmp\SMP\libgmp.vcxproj"
    Update-VSProject -ProjectPath "..\..\zlib\SMP\libzlib.vcxproj"
    Update-VSProject -ProjectPath "..\..\nettle\SMP\libnettle.vcxproj"
    Update-VSProject -ProjectPath "..\..\nettle\SMP\libhogweed.vcxproj"

    Invoke-MSBuildProject -ProjectPath "..\..\gmp\SMP\libgmp.vcxproj" -Configuration "Release"
    Invoke-MSBuildProject -ProjectPath "..\..\zlib\SMP\libzlib.vcxproj" -Configuration "Release"
    Invoke-MSBuildProject -ProjectPath "..\..\nettle\SMP\libnettle.vcxproj" -Configuration "Release"
    Invoke-MSBuildProject -ProjectPath "..\..\nettle\SMP\libhogweed.vcxproj" -Configuration "Release"
    Invoke-MSBuildProject -ProjectPath "libgnutls.vcxproj" -Configuration "ReleaseDLLStaticDeps"

    Remove-Item "$prefix_path\lib\gnutls$lib_postfix.lib" -Force
    Remove-Item "$prefix_path\bin\gnutls$lib_postfix.dll" -Force
    Copy-Item "..\..\..\msvc\lib\x64\gnutls.lib" "$prefix_path\lib\" -Force
    Copy-Item "..\..\..\msvc\bin\x64\gnutls.dll" "$prefix_path\bin\" -Force

    New-PkgConfigFile -Name "gnutls" -Description "gnutls" -Version $gnutls_version `
      -Prefix $prefix_path_forward -Libs "-lgnutls" `
      -Cflags "-I`${includedir}" -OutputPath "$prefix_path\lib\pkgconfig\gnutls.pc"
  } finally {
    Pop-Location
  }
}

function Build-LibPNG {
  Write-Host "Building libpng" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "libpng-$libpng_version")) {
      $tar_file = "$downloads_path\libpng-$libpng_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "libpng-$libpng_version"
    & patch -p1 -N -i "$downloads_path\libpng-pkgconf.patch" 2>&1 | Out-Null

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward

    if ($build_type -eq "debug") {
      Copy-Item "$prefix_path\lib\libpng16d.lib" "$prefix_path\lib\png16.lib" -Force
    }
  } finally {
    Pop-Location
  }
}

function Build-LibJPEG {
  Write-Host "Building libjpeg" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "libjpeg-turbo-$libjpeg_version")) {
      $tar_file = "$downloads_path\libjpeg-turbo-$libjpeg_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "libjpeg-turbo-$libjpeg_version"

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @(
        "-DBUILD_SHARED_LIBS=ON",
        "-DENABLE_SHARED=ON",
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      )
  } finally {
    Pop-Location
  }
}

function Build-PCRE2 {
  Write-Host "Building pcre2" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "pcre2-$pcre2_version")) {
      $tar_file = "$downloads_path\pcre2-$pcre2_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "pcre2-$pcre2_version"

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @(
        "-DBUILD_SHARED_LIBS=ON",
        "-DBUILD_STATIC_LIBS=OFF",
        "-DPCRE2_BUILD_PCRE2_16=ON",
        "-DPCRE2_BUILD_PCRE2_32=ON",
        "-DPCRE2_BUILD_PCRE2_8=ON",
        "-DPCRE2_BUILD_TESTS=OFF",
        "-DPCRE2_SUPPORT_UNICODE=ON"
      )
  } finally {
    Pop-Location
  }
}

function Build-BZip2 {
  Write-Host "Building bzip2" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "bzip2-$bzip2_version")) {
      $tar_file = "$downloads_path\bzip2-$bzip2_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "bzip2-$bzip2_version"
    & patch -p1 -N -i "$downloads_path\bzip2-cmake.patch" 2>&1 | Out-Null

    Invoke-CMakeBuild -source_path "." -build_path "build2" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @("-DCMAKE_POLICY_VERSION_MINIMUM=3.5")
  } finally {
    Pop-Location
  }
}

function Build-XZ {
  Write-Host "Building xz" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "xz-$xz_version")) {
      $tar_file = "$downloads_path\xz-$xz_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "xz-$xz_version"

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @(
        "-DBUILD_SHARED_LIBS=ON",
        "-DBUILD_STATIC_LIBS=OFF",
        "-DBUILD_TESTING=OFF",
        "-DXZ_NLS=OFF"
      )
  } finally {
    Pop-Location
  }
}

function Build-Brotli {
  Write-Host "Building brotli" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "brotli-$brotli_version")) {
      $tar_file = "$downloads_path\brotli-$brotli_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "brotli-$brotli_version"

    Invoke-CMakeBuild -source_path "." -build_path "build2" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @("-DBUILD_TESTING=OFF")
  } finally {
    Pop-Location
  }
}

function Build-LibIconv {
  Write-Host "Building libiconv" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "libiconv-for-Windows")) {
      New-Item -ItemType Directory -Path "libiconv-for-Windows" -Force | Out-Null
      Copy-Item "$downloads_path\libiconv-for-Windows\*" "libiconv-for-Windows\" -Recurse -Force
    }

    Set-Location "libiconv-for-Windows"

    Invoke-MSBuildProject -ProjectPath "libiconv.sln" -Configuration $build_type

    Copy-Item "output\x64\$build_type\*.lib" "$prefix_path\lib\" -Force
    Copy-Item "output\x64\$build_type\*.dll" "$prefix_path\bin\" -Force
    Copy-Item "include\*.h" "$prefix_path\include\" -Force

    if ($build_type -eq "debug") {
      Copy-Item "$prefix_path\lib\libiconvD.lib" "$prefix_path\lib\libiconv.lib" -Force
    }
  } finally {
    Pop-Location
  }
}

function Build-ICU4C {
  Write-Host "Building icu4c" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "icu")) {
      $tar_file = "$downloads_path\icu4c-$icu4c_version-sources.tgz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "icu\source\allinone"

    Invoke-MSBuildProject -ProjectPath "allinone.sln" -Configuration $build_type `
      -Platform "x64" -additional_args @("/p:SkipUWP=true")

    Set-Location "..\..\"

    if (-not (Test-Path "$prefix_path\include\unicode")) {
      New-Item -ItemType Directory -Path "$prefix_path\include\unicode" -Force | Out-Null
    }

    Copy-Item "include\unicode\*.h" "$prefix_path\include\unicode\" -Force
    Copy-Item "lib64\*.*" "$prefix_path\lib\" -Force
    Copy-Item "bin64\*.*" "$prefix_path\bin\" -Force

    # Create pkg-config files
    New-PkgConfigFile -Name "icu-uc" -Description "International Components for Unicode: Common and Data libraries" `
      -Version $icu4c_version -Prefix $prefix_path_forward `
      -Libs "-licuuc$lib_postfix -licudt" -Cflags "-I`${includedir}" `
      -OutputPath "$prefix_path\lib\pkgconfig\icu-uc.pc"

    New-PkgConfigFile -Name "icu-i18n" -Description "International Components for Unicode: Stream and I/O Library" `
      -Version $icu4c_version -Prefix $prefix_path_forward `
      -Libs "-licuin$lib_postfix" -Requires "icu-uc" `
      -OutputPath "$prefix_path\lib\pkgconfig\icu-i18n.pc"

    New-PkgConfigFile -Name "icu-io" -Description "International Components for Unicode: Stream and I/O Library" `
      -Version $icu4c_version -Prefix $prefix_path_forward `
      -Libs "-licuio$lib_postfix" -Requires "icu-i18n" `
      -OutputPath "$prefix_path\lib\pkgconfig\icu-io.pc"
  } finally {
    Pop-Location
  }
}

function Build-Pixman {
  Write-Host "Building pixman" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "pixman-$pixman_version")) {
      $tar_file = "$downloads_path\pixman-$pixman_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "pixman-$pixman_version"

    Invoke-MesonBuild -source_path "." -build_path "build" `
      -build_type $meson_build_type -install_prefix $prefix_path `
      -pkg_config_path "$prefix_path\lib\pkgconfig" `
      -additional_args @("-Dgtk=disabled", "-Dlibpng=enabled")
  } finally {
    Pop-Location
  }
}

function Build-Expat {
  Write-Host "Building expat" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "expat-$expat_version")) {
      $tar_file = "$downloads_path\expat-$expat_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "expat-$expat_version"

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @(
        "-DEXPAT_SHARED_LIBS=ON",
        "-DEXPAT_BUILD_DOCS=OFF",
        "-DEXPAT_BUILD_EXAMPLES=OFF",
        "-DEXPAT_BUILD_FUZZERS=OFF",
        "-DEXPAT_BUILD_TESTS=OFF",
        "-DEXPAT_BUILD_TOOLS=OFF",
        "-DEXPAT_BUILD_PKGCONFIG=ON"
      )
  } finally {
    Pop-Location
  }
}

function Build-Boost {
  Write-Host "Building boost" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "boost_$boost_version_UNDERSCORE")) {
      $tar_file = "$downloads_path\boost_$boost_version_UNDERSCORE.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "boost_$boost_version_UNDERSCORE"

    if (Test-Path "b2.exe") { Remove-Item "b2.exe" -Force }
    if (Test-Path "bjam.exe") { Remove-Item "bjam.exe" -Force }
    if (Test-Path "stage") { Remove-Item "stage" -Recurse -Force }

    Write-Host "Running bootstrap.bat" -ForegroundColor Cyan
    & .\bootstrap.bat msvc
    if ($LASTEXITCODE -ne 0) { throw "Boost bootstrap failed" }

    Write-Host "Running b2.exe" -ForegroundColor Cyan
    & .\b2.exe -a -q -j 4 -d1 --ignore-site-config --stagedir="stage" --layout="tagged" `
      --prefix="$prefix_path" --exec-prefix="$prefix_path\bin" --libdir="$prefix_path\lib" `
      --includedir="$prefix_path\include" --with-headers toolset=msvc architecture=x86 `
      address-model=64 link=shared runtime-link=shared threadapi=win32 threading=multi `
      variant=$build_type install
  } finally {
    Pop-Location
  }
}

function Build-LibXML2 {
  Write-Host "Building libxml2" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "libxml2-v$libxml2_version")) {
      $tar_file = "$downloads_path\libxml2-v$libxml2_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "libxml2-v$libxml2_version"

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @(
        "-DBUILD_SHARED_LIBS=ON",
        "-DLIBXML2_WITH_PYTHON=OFF",
        "-DLIBXML2_WITH_ZLIB=ON",
        "-DLIBXML2_WITH_LZMA=ON",
        "-DLIBXML2_WITH_ICONV=ON",
        "-DLIBXML2_WITH_ICU=ON",
        "-DICU_ROOT=$prefix_path_forward"
      )

    if ($build_type -eq "debug") {
      Copy-Item "$prefix_path\lib\libxml2d.lib" "$prefix_path\lib\libxml2.lib" -Force
    }
  } finally {
    Pop-Location
  }
}

function Build-NGHttp2 {
  Write-Host "Building nghttp2" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "nghttp2-$nghttp2_version")) {
      $tar_file = "$downloads_path\nghttp2-$nghttp2_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "nghttp2-$nghttp2_version"

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @(
        "-DBUILD_SHARED_LIBS=ON",
        "-DBUILD_STATIC_LIBS=OFF"
      )
  } finally {
    Pop-Location
  }
}

function Build-LibFFI {
  Write-Host "Building libffi" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "libffi")) {
      New-Item -ItemType Directory -Path "libffi" -Force | Out-Null
      Copy-Item "$downloads_path\libffi\*" "libffi\" -Recurse -Force
    }

    Set-Location "libffi"

    Invoke-MesonBuild -source_path "." -build_path "build" `
      -build_type $meson_build_type -install_prefix $prefix_path `
      -additional_args @("-Dpkg_config_path=$prefix_path\lib\pkgconfig")
  } finally {
    Pop-Location
  }
}

function Build-DlfcnWin32 {
  Write-Host "Building dlfcn-win32" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "dlfcn-win32-$dlfcn_version")) {
      $tar_file = "$downloads_path\dlfcn-win32-$dlfcn_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "dlfcn-win32-$dlfcn_version"

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @("-DBUILD_SHARED_LIBS=ON")
  } finally {
    Pop-Location
  }
}

function Build-LibPSL {
  Write-Host "Building libpsl" -ForegroundColor Yellow

  $originalCFLAGS = $env:CFLAGS
  $originalLDFLAGS = $env:LDFLAGS

  try {
    $env:CFLAGS = "-I$prefix_path_forward/include"
    $env:LDFLAGS = "-L$prefix_path\lib"

    Push-Location $build_path
    try {
      if (-not (Test-Path "libpsl-$libpsl_version")) {
        $tar_file = "$downloads_path\libpsl-$libpsl_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
      }

      Set-Location "libpsl-$libpsl_version"
      & patch -p1 -N -i "$downloads_path\libpsl-time.patch" 2>&1 | Out-Null

      Invoke-MesonBuild -source_path "." -build_path "build" `
        -build_type $meson_build_type -install_prefix $prefix_path `
        -pkg_config_path "$prefix_path\lib\pkgconfig"
    } finally {
      Pop-Location
    }
  } finally {
    $env:CFLAGS = $originalCFLAGS
    $env:LDFLAGS = $originalLDFLAGS
  }
}

function Build-Orc {
  Write-Host "Building orc" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "orc-$orc_version")) {
      & 7z x "$downloads_path\orc-$orc_version.tar.xz" -so | & 7z x -aoa -si"orc-$orc_version.tar"
    }

    Set-Location "orc-$orc_version"

    Invoke-MesonBuild -source_path "." -build_path "build" `
      -build_type $meson_build_type -install_prefix $prefix_path `
      -pkg_config_path "$prefix_path\lib\pkgconfig"
  } finally {
    Pop-Location
  }
}

function Build-SQLite {
  Write-Host "Building sqlite" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "sqlite-autoconf-$sqlite_version")) {
      $tar_file = "$downloads_path\sqlite-autoconf-$sqlite_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "sqlite-autoconf-$sqlite_version"

    & cl -DSQLITE_API="__declspec(dllexport)" -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_COLUMN_METADATA sqlite3.c -link -dll -out:sqlite3.dll
    & cl shell.c sqlite3.c -Fe:sqlite3.exe

    Copy-Item "*.h" "$prefix_path\include\" -Force
    Copy-Item "*.lib" "$prefix_path\lib\" -Force
    Copy-Item "*.dll" "$prefix_path\bin\" -Force
    Copy-Item "*.exe" "$prefix_path\bin\" -Force

    New-PkgConfigFile -Name "SQLite" -Description "SQL database engine" `
      -Version "3.38.1" -Prefix $prefix_path_forward `
      -Libs "-lsqlite3" -Cflags "-I`${includedir}" `
      -OutputPath "$prefix_path\lib\pkgconfig\sqlite3.pc"
  } finally {
    Pop-Location
  }
}

function Build-Glib {
  Write-Host "Building glib" -ForegroundColor Yellow

  $originalCFLAGS = $env:CFLAGS
  $originalLDFLAGS = $env:LDFLAGS

  try {
    $env:CFLAGS = "-I$prefix_path_forward/include"
    $env:LDFLAGS = "-L$prefix_path\lib"

    Push-Location $build_path
    try {
      if (-not (Test-Path "glib-$glib_version")) {
        & 7z x "$downloads_path\glib-$glib_version.tar.xz" -so | & 7z x -aoa -si"glib-$glib_version.tar"
      }

      Set-Location "glib-$glib_version"

      Invoke-MesonBuild -source_path "." -build_path "build" `
        -build_type $meson_build_type -install_prefix $prefix_path `
        -additional_args @(
          "--includedir=$prefix_path\include",
          "--libdir=$prefix_path\lib",
          "-Dpkg_config_path=$prefix_path\lib\pkgconfig",
          "-Dtests=false"
        )
    } finally {
      Pop-Location
    }
  } finally {
    $env:CFLAGS = $originalCFLAGS
    $env:LDFLAGS = $originalLDFLAGS
  }
}

function Build-LibSoup {
  Write-Host "Building libsoup" -ForegroundColor Yellow

  $originalCFLAGS = $env:CFLAGS

  try {
    $env:CFLAGS = "-I$prefix_path_forward/include"

    Push-Location $build_path
    try {
      if (-not (Test-Path "libsoup-$libsoup_version")) {
        & 7z x "$downloads_path\libsoup-$libsoup_version.tar.xz" -so | & 7z x -aoa -si"libsoup-$libsoup_version.tar"
      }

      Set-Location "libsoup-$libsoup_version"

      Invoke-MesonBuild -source_path "." -build_path "build" `
        -build_type $meson_build_type -install_prefix $prefix_path `
        -pkg_config_path "$prefix_path\lib\pkgconfig" `
        -additional_args @(
          "-Dtests=false",
          "-Dvapi=disabled",
          "-Dgssapi=disabled",
          "-Dintrospection=disabled",
          "-Dsysprof=disabled",
          "-Dtls_check=false"
        )
    } finally {
      Pop-Location
    }
  } finally {
    $env:CFLAGS = $originalCFLAGS
  }
}

function Build-GlibNetworking {
  Write-Host "Building glib-networking" -ForegroundColor Yellow

  $originalCFLAGS = $env:CFLAGS

  try {
    $env:CFLAGS = "-I$prefix_path_forward/include"

    Push-Location $build_path
    try {
      if (-not (Test-Path "glib-networking-$glib_networking_version")) {
        & 7z x "$downloads_path\glib-networking-$glib_networking_version.tar.xz" -so | & 7z x -aoa -si"glib-networking-$glib_networking_version.tar"
      }

      Set-Location "glib-networking-$glib_networking_version"

      Invoke-MesonBuild -source_path "." -build_path "build" `
        -build_type $meson_build_type -install_prefix $prefix_path `
        -pkg_config_path "$prefix_path\lib\pkgconfig" `
        -additional_args @(
          "-Dgnutls=enabled",
          "-Dopenssl=enabled",
          "-Dgnome_proxy=disabled",
          "-Dlibproxy=disabled"
        )
    } finally {
      Pop-Location
    }
  } finally {
    $env:CFLAGS = $originalCFLAGS
  }
}

function Build-Freetype {
  Write-Host "Building freetype without harfbuzz" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "freetype-$freetype_version")) {
      $tar_file = "$downloads_path\freetype-$freetype_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "freetype-$freetype_version"

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @(
        "-DBUILD_SHARED_LIBS=ON",
        "-DFT_DISABLE_HARFBUZZ=ON"
      )

    if ($build_type -eq "debug") {
      Copy-Item "$prefix_path\lib\freetyped.lib" "$prefix_path\lib\freetype.lib" -Force
    }
  } finally {
    Pop-Location
  }
}

function Build-Harfbuzz {
  Write-Host "Building harfbuzz" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "harfbuzz-$harfbuzz_version")) {
      $tar_file = "$downloads_path\harfbuzz-$harfbuzz_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "harfbuzz-$harfbuzz_version"

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @("-DBUILD_SHARED_LIBS=ON")
  } finally {
    Pop-Location
  }
}

# Add more audio codec build functions (abbreviated for space)
function Build-Flac {
  Write-Host "Building flac" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    $tar_file = "$downloads_path\flac-$global:flac_version.tar.xz"
    if (-not (Test-Path $tar_file)) {
      throw "flac archive not found: $tar_file"
    }

    Write-Host "Extracting $tar_file" -ForegroundColor Cyan
    $relative_tar_path = Resolve-Path -Relative $tar_file
    & tar -xf $relative_tar_path
    if ($LASTEXITCODE -ne 0) { throw "Failed to extract flac archive" }

    $extract_dir = Get-ChildItem -Directory -Filter "flac-*" | Select-Object -First 1
    if (-not $extract_dir) { throw "Extracted directory not found for flac" }

    Push-Location $extract_dir.FullName
    try {
      Invoke-CMakeBuild `
        -source_path "." `
        -build_path "build2" `
        -generator $cmake_generator `
        -build_type $cmake_build_type `
        -install_prefix $prefix_path_forward `
        -additional_args @(
          "-DBUILD_SHARED_LIBS=ON",
          "-DBUILD_DOCS=OFF",
          "-DBUILD_EXAMPLES=OFF",
          "-DINSTALL_MANPAGES=OFF",
          "-DBUILD_TESTING=OFF",
          "-DBUILD_PROGRAMS=OFF"
        )

      Write-Host "flac built successfully!" -ForegroundColor Green
    } finally {
      Pop-Location
    }
  } finally {
    Pop-Location
  }
}

function Build-Wavpack {
  Write-Host "Building wavpack" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    $tar_file = "$downloads_path\wavpack-$global:wavpack_version.tar.bz2"
    if (-not (Test-Path $tar_file)) {
      throw "wavpack archive not found: $tar_file"
    }

    Write-Host "Extracting $tar_file" -ForegroundColor Cyan
    $relative_tar_path = Resolve-Path -Relative $tar_file
    & tar -xf $relative_tar_path
    if ($LASTEXITCODE -ne 0) { throw "Failed to extract wavpack archive" }

    $extract_dir = Get-ChildItem -Directory -Filter "wavpack-*" | Select-Object -First 1
    if (-not $extract_dir) { throw "Extracted directory not found for wavpack" }

    Push-Location $extract_dir.FullName
    try {
      Invoke-CMakeBuild `
        -source_path "." `
        -build_path "build" `
        -generator $cmake_generator `
        -build_type $cmake_build_type `
        -install_prefix $prefix_path_forward `
        -additional_args @(
          "-DBUILD_SHARED_LIBS=ON",
          "-DBUILD_TESTING=OFF",
          "-DWAVPACK_BUILD_DOCS=OFF",
          "-DWAVPACK_BUILD_PROGRAMS=OFF",
          "-DWAVPACK_ENABLE_ASM=OFF",
          "-DWAVPACK_ENABLE_LEGACY=OFF",
          "-DWAVPACK_BUILD_WINAMP_PLUGIN=OFF",
          "-DWAVPACK_BUILD_COOLEDIT_PLUGIN=OFF"
        )

      # Copy wavpackdll.lib to wavpack.lib
      if (-not (Test-Path "$prefix_path\include\wavpack")) {
        New-Item -ItemType Directory -Path "$prefix_path\include\wavpack" -Force | Out-Null
      }
      Copy-Item "$prefix_path\lib\wavpackdll.lib" "$prefix_path\lib\wavpack.lib" -Force

      Write-Host "wavpack built successfully!" -ForegroundColor Green
    } finally {
      Pop-Location
    }
  } finally {
    Pop-Location
  }
}

function Build-Opus {
  Write-Host "Building opus" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    $tar_file = "$downloads_path\opus-$global:opus_version.tar.gz"
    if (-not (Test-Path $tar_file)) {
      throw "opus archive not found: $tar_file"
    }

    Write-Host "Extracting $tar_file" -ForegroundColor Cyan
    $relative_tar_path = Resolve-Path -Relative $tar_file
    & tar -xf $relative_tar_path
    if ($LASTEXITCODE -ne 0) { throw "Failed to extract opus archive" }

    $extract_dir = Get-ChildItem -Directory -Filter "opus-*" | Select-Object -First 1
    if (-not $extract_dir) { throw "Extracted directory not found for opus" }

    Push-Location $extract_dir.FullName
    try {
      # Remove problematic line from CMakeLists.txt
      $cmake_file = "CMakeLists.txt"
      $content = Get-Content $cmake_file | Where-Object { $_ -notmatch "include\(opus_buildtype\.cmake\)" }
      $content | Set-Content $cmake_file

      Invoke-CMakeBuild `
        -source_path "." `
        -build_path "build" `
        -generator $cmake_generator `
        -build_type $cmake_build_type `
        -install_prefix $prefix_path_forward `
        -additional_args @("-DBUILD_SHARED_LIBS=ON")

      Write-Host "opus built successfully!" -ForegroundColor Green
    } finally {
      Pop-Location
    }
  } finally {
    Pop-Location
  }
}

function Build-Opusfile {
  Write-Host "Building opusfile" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    $tar_file = "$downloads_path\opusfile-$global:opusfile_version.tar.gz"
    if (-not (Test-Path $tar_file)) {
      throw "opusfile archive not found: $tar_file"
    }

    Write-Host "Extracting $tar_file" -ForegroundColor Cyan
    $relative_tar_path = Resolve-Path -Relative $tar_file
    & tar -xf $relative_tar_path
    if ($LASTEXITCODE -ne 0) { throw "Failed to extract opusfile archive" }

    $extract_dir = Get-ChildItem -Directory -Filter "opusfile-*" | Select-Object -First 1
    if (-not $extract_dir) { throw "Extracted directory not found for opusfile" }

    Push-Location $extract_dir.FullName
    try {
      # Apply patch
      $patch_file = "$downloads_path\opusfile-cmake.patch"
      if (Test-Path $patch_file) {
        Write-Host "Applying opusfile patch..." -ForegroundColor Cyan
        & patch -p1 -N -i $patch_file
      }

      Invoke-CMakeBuild `
        -source_path "." `
        -build_path "build" `
        -generator $cmake_generator `
        -build_type $cmake_build_type `
        -install_prefix $prefix_path_forward `
        -additional_args @(
          "-DBUILD_SHARED_LIBS=ON",
          "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
        )

      Write-Host "opusfile built successfully!" -ForegroundColor Green
    } finally {
      Pop-Location
    }
  } finally {
    Pop-Location
  }
}

function Build-Speex {
  Write-Host "Building speex" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    $tar_file = "$downloads_path\speex-Speex-$global:speex_version.tar.gz"
    if (-not (Test-Path $tar_file)) {
      throw "speex archive not found: $tar_file"
    }

    Write-Host "Extracting $tar_file" -ForegroundColor Cyan
    $relative_tar_path = Resolve-Path -Relative $tar_file
    & tar -xf $relative_tar_path
    if ($LASTEXITCODE -ne 0) { throw "Failed to extract speex archive" }

    $extract_dir = Get-ChildItem -Directory -Filter "speex-Speex-*" | Select-Object -First 1
    if (-not $extract_dir) { throw "Extracted directory not found for speex" }

    Push-Location $extract_dir.FullName
    try {
      # Apply patch
      $patch_file = "$downloads_path\speex-cmake.patch"
      if (Test-Path $patch_file) {
        Write-Host "Applying speex patch..." -ForegroundColor Cyan
        & patch -p1 -N -i $patch_file
      }

      Invoke-CMakeBuild `
        -source_path "." `
        -build_path "build" `
        -generator $cmake_generator `
        -build_type $cmake_build_type `
        -install_prefix $prefix_path_forward `
        -additional_args @("-DBUILD_SHARED_LIBS=ON")

      # Handle library naming for debug builds
      if ($build_type -eq "debug") {
        if (Test-Path "$prefix_path\lib\libspeexd.lib") {
          Copy-Item "$prefix_path\lib\libspeexd.lib" "$prefix_path\lib\libspeex.lib" -Force
        }
        if (Test-Path "$prefix_path\bin\libspeexd.dll") {
          Copy-Item "$prefix_path\bin\libspeexd.dll" "$prefix_path\bin\libspeex.dll" -Force
        }
      }

      Write-Host "speex built successfully!" -ForegroundColor Green
    } finally {
      Pop-Location
    }
  } finally {
    Pop-Location
  }
}

function Build-MPG123 {
  Write-Host "Building mpg123" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    $tar_file = "$downloads_path\mpg123-$global:mpg123_version.tar.bz2"
    if (-not (Test-Path $tar_file)) {
      throw "mpg123 archive not found: $tar_file"
    }

    Write-Host "Extracting $tar_file" -ForegroundColor Cyan
    $relative_tar_path = Resolve-Path -Relative $tar_file
    & tar -xf $relative_tar_path
    if ($LASTEXITCODE -ne 0) { throw "Failed to extract mpg123 archive" }

    $extract_dir = Get-ChildItem -Directory -Filter "mpg123-*" | Select-Object -First 1
    if (-not $extract_dir) { throw "Extracted directory not found for mpg123" }

    Push-Location $extract_dir.FullName
    try {
      Invoke-CMakeBuild `
        -source_path "ports/cmake" `
        -build_path "build2" `
        -generator $cmake_generator `
        -build_type $cmake_build_type `
        -install_prefix $prefix_path_forward `
        -additional_args @(
          "-DBUILD_SHARED_LIBS=ON",
          "-DBUILD_PROGRAMS=OFF",
          "-DBUILD_LIBOUT123=OFF",
          "-DYASM_ASSEMBLER=$prefix_path_forward/bin/vsyasm.exe"
        )

      Write-Host "mpg123 built successfully!" -ForegroundColor Green
    } finally {
      Pop-Location
    }
  } finally {
    Pop-Location
  }
}

function Build-Lame {
  Write-Host "Building lame" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    $tar_file = "$downloads_path\lame-$global:lame_version.tar.gz"
    if (-not (Test-Path $tar_file)) {
      throw "lame archive not found: $tar_file"
    }

    Write-Host "Extracting $tar_file" -ForegroundColor Cyan
    $relative_tar_path = Resolve-Path -Relative $tar_file
    & tar -xf $relative_tar_path
    if ($LASTEXITCODE -ne 0) { throw "Failed to extract lame archive" }

    $extract_dir = Get-ChildItem -Directory -Filter "lame-*" | Select-Object -First 1
    if (-not $extract_dir) { throw "Extracted directory not found for lame" }

    Push-Location $extract_dir.FullName
    try {
      # Fix Makefile.MSVC for x64
      $makefile = "Makefile.MSVC"
      if (Test-Path $makefile) {
        (Get-Content $makefile) -replace "MACHINE = /machine:.*", "MACHINE = /machine:X64" | Set-Content $makefile
      }

      # Build with nmake
      Write-Host "Building with nmake..." -ForegroundColor Cyan
      & nmake -f Makefile.MSVC MSVCVER=Win64 libmp3lame.dll
      if ($LASTEXITCODE -ne 0) { throw "nmake build failed" }

      # Copy files
      Copy-Item "include\*.h" "$prefix_path\include\" -Force
      Copy-Item "output\libmp3lame*.lib" "$prefix_path\lib\" -Force
      Copy-Item "output\libmp3lame*.dll" "$prefix_path\bin\" -Force

      # Create pkgconfig file
      $pc_dir = "$prefix_path\lib\pkgconfig"
      if (-not (Test-Path $pc_dir)) {
        New-Item -ItemType Directory -Path $pc_dir -Force | Out-Null
      }

      $pc_content = @"
prefix=$prefix_path_forward
exec_prefix=$prefix_path_forward
libdir=$prefix_path_forward/lib
includedir=$prefix_path_forward/include

Name: lame
Description: encoder that converts audio to the MP3 file format.
URL: https://lame.sourceforge.io/
Version: $global:lame_version
Libs: -L`${libdir} -lmp3lame
Cflags: -I`${includedir}
"@
      $pc_content | Out-File -FilePath "$pc_dir\mp3lame.pc" -Encoding ASCII

      Write-Host "lame built successfully!" -ForegroundColor Green
    } finally {
      Pop-Location
    }
  } finally {
    Pop-Location
  }
}

function Build-Twolame {
  Write-Host "Building twolame" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    $tar_file = "$downloads_path\twolame-$global:twolame_version.tar.gz"
    if (-not (Test-Path $tar_file)) {
      throw "twolame archive not found: $tar_file"
    }

    Write-Host "Extracting $tar_file" -ForegroundColor Cyan
    $relative_tar_path = Resolve-Path -Relative $tar_file
    & tar -xf $relative_tar_path
    if ($LASTEXITCODE -ne 0) { throw "Failed to extract twolame archive" }

    $extract_dir = Get-ChildItem -Directory -Filter "twolame-*" | Select-Object -First 1
    if (-not $extract_dir) { throw "Extracted directory not found for twolame" }

    Push-Location $extract_dir.FullName
    try {
      # Apply patch
      $patch_file = "$downloads_path\twolame.patch"
      if (Test-Path $patch_file) {
        Write-Host "Applying twolame patch..." -ForegroundColor Cyan
        & patch -p1 -N -i $patch_file
      }

      Push-Location "win32"
      try {
        # Upgrade solution
        Write-Host "Upgrading Visual Studio solution..." -ForegroundColor Cyan
        & devenv.exe libtwolame_dll.sln /upgrade
        Start-Sleep -Seconds 5

        # Fix platform in solution files
        $sln_file = "libtwolame_dll.sln"
        $vcxproj_file = "libtwolame_dll.vcxproj"

        if (Test-Path $sln_file) {
          (Get-Content $sln_file) -replace "Win32", "x64" | Set-Content $sln_file
        }
        if (Test-Path $vcxproj_file) {
          (Get-Content $vcxproj_file) -replace "Win32", "x64" | Set-Content $vcxproj_file
          (Get-Content $vcxproj_file) -replace "MachineX86", "MachineX64" | Set-Content $vcxproj_file
        }

        # Build with MSBuild
        Invoke-MSBuildProject `
          -project_file "libtwolame_dll.sln" `
          -configuration $build_type

        # Copy files
        Copy-Item "..\libtwolame\twolame.h" "$prefix_path\include\" -Force
        Copy-Item "lib\*.lib" "$prefix_path\lib\" -Force
        Copy-Item "lib\*.dll" "$prefix_path\bin\" -Force

        # Create pkgconfig file
        $pc_dir = "$prefix_path\lib\pkgconfig"
        if (-not (Test-Path $pc_dir)) {
          New-Item -ItemType Directory -Path $pc_dir -Force | Out-Null
        }

        $pc_content = @"
prefix=$prefix_path_forward
exec_prefix=$prefix_path_forward
libdir=$prefix_path_forward/lib
includedir=$prefix_path_forward/include

Name: twolame
Description: MPEG Audio Layer 2 encoder
URL: http://www.twolame.org/
Version: $global:twolame_version
Libs: -L`${libdir} -ltwolame_dll
Cflags: -I`${includedir}
"@
        $pc_content | Out-File -FilePath "$pc_dir\twolame.pc" -Encoding ASCII

        Write-Host "twolame built successfully!" -ForegroundColor Green
      } finally {
        Pop-Location
      }
    } finally {
      Pop-Location
    }
  } finally {
    Pop-Location
  }
}

function Build-FFmpeg {
  Write-Host "Building ffmpeg" -ForegroundColor Yellow

  $originalCFLAGS = $env:CFLAGS

  try {
    $env:CFLAGS = "-I$prefix_path_forward/include"

    Push-Location $build_path
    try {
      if (-not (Test-Path "ffmpeg")) {
        New-Item -ItemType Directory -Path "ffmpeg" -Force | Out-Null
        Copy-Item "$downloads_path\ffmpeg\*" "ffmpeg\" -Recurse -Force
        Set-Location "ffmpeg"
        & git checkout "meson-$ffmpeg_version"
        & git checkout .
        & git pull --rebase
        Set-Location ..
      }

      Set-Location "ffmpeg"

      Invoke-MesonBuild -source_path "." -build_path "build" `
        -build_type $meson_build_type -install_prefix $prefix_path `
        -pkg_config_path "$prefix_path\lib\pkgconfig" `
        -additional_args @(
          "-Dtests=disabled",
          "-Dgpl=enabled"
        )
    } finally {
      Pop-Location
    }
  } finally {
    $env:CFLAGS = $originalCFLAGS
  }
}

function Build-Chromaprint {
  Write-Host "Building chromaprint" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "chromaprint-$chromaprint_version")) {
      $tar_file = "$downloads_path\chromaprint-$chromaprint_version.tar.gz"
      $relative_tar_path = Resolve-Path -Relative $tar_file
      & tar -xf $relative_tar_path
    }

    Set-Location "chromaprint-$chromaprint_version"

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @(
        "-DBUILD_SHARED_LIBS=ON",
        "-DFFMPEG_ROOT=$prefix_path",
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      )
  } finally {
    Pop-Location
  }
}

function Build-GStreamer {
  Write-Host "Building GStreamer" -ForegroundColor Yellow

  $originalCFLAGS = $env:CFLAGS

  try {
    $env:CFLAGS = "-I$prefix_path_forward/include"

    Push-Location $build_path
    try {
      if ($gst_dev -eq "ON") {
        if (-not (Test-Path "gstreamer")) {
          New-Item -ItemType Directory -Path "gstreamer" -Force | Out-Null
          Copy-Item "$downloads_path\gstreamer\subprojects\gstreamer\*" "gstreamer\" -Recurse -Force
        }
      } else {
        if (-not (Test-Path "gstreamer-$gstreamer_version")) {
          & 7z x "$downloads_path\gstreamer-$gstreamer_version.tar.xz" -so | & 7z x -aoa -si"gstreamer-$gstreamer_version.tar"
        }
        Set-Location "gstreamer-$gstreamer_version"
      }

      Invoke-MesonBuild -source_path (Get-Location).Path -build_path "build" `
        -build_type $meson_build_type -install_prefix $prefix_path `
        -pkg_config_path "$prefix_path\lib\pkgconfig" `
        -additional_args @(
          "-Dexamples=disabled",
          "-Dtests=disabled",
          "-Dbenchmarks=disabled",
          "-Dtools=enabled",
          "-Dintrospection=disabled",
          "-Dnls=disabled",
          "-Ddoc=disabled",
          "-Dgst_debug=true",
          "-Dgst_parse=true",
          "-Dregistry=true"
        )
    } finally {
      Pop-Location
    }
  } finally {
    $env:CFLAGS = $originalCFLAGS
  }
}

function Build-Qt {
  Write-Host "Building qtbase" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if ($qt_dev -eq "ON") {
      if (-not (Test-Path "qtbase")) {
        New-Item -ItemType Directory -Path "qtbase" -Force | Out-Null
        Copy-Item "$downloads_path\qtbase\*" "qtbase\" -Recurse -Force
      }
      Set-Location "qtbase"
    } else {
      if (-not (Test-Path "qtbase-everywhere-src-$qt_version")) {
        & 7z x "$downloads_path\qtbase-everywhere-src-$qt_version.tar.xz" -so | & 7z x -aoa -si"qtbase-everywhere-src-$qt_version.tar"
      }
      Set-Location "qtbase-everywhere-src-$qt_version"
    }

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator "Ninja" -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @(
        "-DBUILD_SHARED_LIBS=ON",
        "-DPKG_CONFIG_EXECUTABLE=$prefix_path_forward/bin/pkgconf.exe",
        "-DQT_BUILD_EXAMPLES=OFF",
        "-DQT_BUILD_TESTS=OFF",
        "-DFEATURE_openssl=ON",
        "-DFEATURE_openssl_linked=ON",
        "-DFEATURE_system_zlib=ON",
        "-DFEATURE_system_png=ON",
        "-DFEATURE_system_jpeg=ON",
        "-DFEATURE_system_pcre2=ON",
        "-DFEATURE_system_freetype=ON",
        "-DFEATURE_system_harfbuzz=ON",
        "-DFEATURE_system_sqlite=ON",
        "-DICU_ROOT=$prefix_path_forward"
      )
  } finally {
    Pop-Location
  }
}

function Build-Strawberry {
  Write-Host "Building strawberry" -ForegroundColor Yellow

  Push-Location $build_path
  try {
    if (-not (Test-Path "strawberry")) {
      New-Item -ItemType Directory -Path "strawberry" -Force | Out-Null
      Copy-Item "$downloads_path\strawberry\*" "strawberry\" -Recurse -Force
    }

    Set-Location "strawberry"

    Invoke-CMakeBuild -source_path "." -build_path "build" `
      -generator $cmake_generator -build_type $cmake_build_type `
      -install_prefix $prefix_path_forward `
      -additional_args @(
        "-DCMAKE_PREFIX_PATH=$prefix_path_forward/lib/cmake",
        "-DARCH=x86_64",
        "-DENABLE_TRANSLATIONS=ON",
        "-DBUILD_WERROR=ON",
        "-DENABLE_WIN32_CONSOLE=OFF",
        "-DICU_ROOT=$prefix_path",
        "-DENABLE_AUDIOCD=OFF",
        "-DENABLE_MTP=OFF",
        "-DENABLE_GPOD=OFF"
      )

    Write-Host "Strawberry built successfully!" -ForegroundColor Green
  } finally {
    Pop-Location
  }
}

#endregion

#region Main Build Logic

Write-Host "Starting build process..." -ForegroundColor Cyan
Write-Host ""

try {
  # Check what needs to be built
  $buildQueue = @()

  if (-not (Test-Path "$prefix_path\bin\yasm.exe")) { $buildQueue += "yasm" }
  if (-not (Test-Path "$prefix_path\bin\pkgconf.exe")) { $buildQueue += "pkgconf" }
  if (-not (Test-Path "$prefix_path\lib\getopt.lib")) { $buildQueue += "getopt-win" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\zlib.pc")) { $buildQueue += "zlib" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\openssl.pc")) { $buildQueue += "openssl" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\gmp.pc")) { $buildQueue += "gmp" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\nettle.pc")) { $buildQueue += "nettle" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\gnutls.pc")) { $buildQueue += "gnutls" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\libpng.pc")) { $buildQueue += "libpng" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\libjpeg.pc")) { $buildQueue += "libjpeg" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\libpcre2-16.pc")) { $buildQueue += "pcre2" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\bzip2.pc")) { $buildQueue += "bzip2" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\liblzma.pc")) { $buildQueue += "xz" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\libbrotlicommon.pc")) { $buildQueue += "brotli" }
  if (-not (Test-Path "$prefix_path\lib\libiconv*.lib")) { $buildQueue += "libiconv" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\icu-uc.pc")) { $buildQueue += "icu4c" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\pixman-1.pc")) { $buildQueue += "pixman" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\expat.pc")) { $buildQueue += "expat" }
  if (-not (Test-Path "$prefix_path\include\boost\config.hpp")) { $buildQueue += "boost" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\libxml-2.0.pc")) { $buildQueue += "libxml2" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\libnghttp2.pc")) { $buildQueue += "nghttp2" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\libffi.pc")) { $buildQueue += "libffi" }
  if (-not (Test-Path "$prefix_path\include\dlfcn.h")) { $buildQueue += "dlfcn-win32" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\libpsl.pc")) { $buildQueue += "libpsl" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\orc-0.4.pc")) { $buildQueue += "orc" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\sqlite3.pc")) { $buildQueue += "sqlite" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\glib-2.0.pc")) { $buildQueue += "glib" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\libsoup-3.0.pc")) { $buildQueue += "libsoup" }
  if (-not (Test-Path "$prefix_path\lib\gio\modules\gioopenssl.lib")) { $buildQueue += "glib-networking" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\freetype2.pc")) { $buildQueue += "freetype" }
  if (-not (Test-Path "$prefix_path\lib\harfbuzz*.lib")) { $buildQueue += "harfbuzz" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\flac.pc")) { $buildQueue += "flac" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\wavpack.pc")) { $buildQueue += "wavpack" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\opus.pc")) { $buildQueue += "opus" }
  if (-not (Test-Path "$prefix_path\bin\opusfile.dll")) { $buildQueue += "opusfile" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\speex.pc")) { $buildQueue += "speex" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\libmpg123.pc")) { $buildQueue += "mpg123" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\mp3lame.pc")) { $buildQueue += "lame" }
  if (-not (Test-Path "$prefix_path\lib\libtwolame_dll.lib")) { $buildQueue += "twolame" }
  if (-not (Test-Path "$prefix_path\lib\avutil.lib")) { $buildQueue += "ffmpeg" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\libchromaprint.pc")) { $buildQueue += "chromaprint" }
  if (-not (Test-Path "$prefix_path\lib\pkgconfig\gstreamer-1.0.pc")) { $buildQueue += "gstreamer" }
  if (-not (Test-Path "$prefix_path\bin\qt-configure-module.bat")) { $buildQueue += "qt" }
  if (-not (Test-Path "$build_path\strawberry\build\strawberrysetup*.exe")) { $buildQueue += "strawberry" }

  if ($buildQueue.Count -eq 0) {
    Write-Host "All dependencies already built!" -ForegroundColor Green
    exit 0
  }

  Write-Host "Build queue: $($buildQueue -join ', ')" -ForegroundColor Cyan
  Write-Host ""

  # Build each component
  foreach ($component in $buildQueue) {
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "Building: $component" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta

    switch ($component) {
      "yasm" { Build-Yasm }
      "pkgconf" { Build-Pkgconf }
      "getopt-win" { Build-GetoptWin }
      "zlib" { Build-Zlib }
      "openssl" { Build-OpenSSL }
      "gmp" { Build-GMP }
      "nettle" { Build-Nettle }
      "gnutls" { Build-GnuTLS }
      "libpng" { Build-LibPNG }
      "libjpeg" { Build-LibJPEG }
      "pcre2" { Build-PCRE2 }
      "bzip2" { Build-BZip2 }
      "xz" { Build-XZ }
      "brotli" { Build-Brotli }
      "libiconv" { Build-LibIconv }
      "icu4c" { Build-ICU4C }
      "pixman" { Build-Pixman }
      "expat" { Build-Expat }
      "boost" { Build-Boost }
      "libxml2" { Build-LibXML2 }
      "nghttp2" { Build-NGHttp2 }
      "libffi" { Build-LibFFI }
      "dlfcn-win32" { Build-DlfcnWin32 }
      "libpsl" { Build-LibPSL }
      "orc" { Build-Orc }
      "sqlite" { Build-SQLite }
      "glib" { Build-Glib }
      "libsoup" { Build-LibSoup }
      "glib-networking" { Build-GlibNetworking }
      "freetype" { Build-Freetype }
      "harfbuzz" { Build-Harfbuzz }
      "flac" { Build-Flac }
      "wavpack" { Build-Wavpack }
      "opus" { Build-Opus }
      "opusfile" { Build-Opusfile }
      "speex" { Build-Speex }
      "mpg123" { Build-MPG123 }
      "lame" { Build-Lame }
      "twolame" { Build-Twolame }
      "ffmpeg" { Build-FFmpeg }
      "chromaprint" { Build-Chromaprint }
      "gstreamer" { Build-GStreamer }
      "qt" { Build-Qt }
      "strawberry" { Build-Strawberry }
      default {
        Write-Warning "Unknown component: $component (skipping)"
      }
    }

    Write-Host "Completed: $component" -ForegroundColor Green
    Write-Host ""
  }

  Write-Host "========================================" -ForegroundColor Green
  Write-Host "Build completed successfully!" -ForegroundColor Green
  Write-Host "========================================" -ForegroundColor Green

} catch {
  Write-Host ""
  Write-Host "========================================" -ForegroundColor Red
  Write-Host "Build failed!" -ForegroundColor Red
  Write-Host "Error: $_" -ForegroundColor Red
  Write-Host "========================================" -ForegroundColor Red
  exit 1
}

#endregion
